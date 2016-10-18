class Agent < ActiveRecord::Base
  STATE_DISABLED = 0
  STATE_OK = 1
  STATE_DISABLED_EOM = 2

  EXTENSION_TYPE_SIP = 1

  belongs_to :company
  belongs_to :salesman
  has_and_belongs_to_many :groups
  has_many :ags, dependent: :destroy
  has_many :cdrs
  has_one  :charge_agent, dependent: :destroy
  has_many :charge_changes, dependent: :destroy
  has_many :extensions
  has_many :disabled_agents, dependent: :destroy

  scope :ok, -> { where(state: STATE_OK) }

  # TODO: Always use the new "sexy" validations. https://github.com/bbatsov/rails-style-guide#meaningful-model-names
  validates :id, uniqueness: true, numericality: { greater_than_or_equal_to: 100011001, less_than: 999999999, only_integer: true }
  validates :company, presence: true
  validates :show_number, presence: true
  validates :salesman, uniqueness: true, allow_nil: true
  validates :code, uniqueness: { scope: :company_id }, numericality: { greater_than_or_equal_to: 1001, less_than: 9999, only_integer: true }

  after_initialize :init

  # 这个方法用于Redis
  def contact_number
    self.transfer? ? self.private_phone : self.id
  end

  def outbound_group
    self.groups.outbound.first
  end

  def outbound_group_id
    self.groups.outbound.first.try(:id)
  end

  def extension_names
    if self.extensions.blank?
      result = I18n.t(:no_extension, w: self.code)
    else
      result = self.extensions.map(&:extension).join('|')
    end

    self.ok? ? result : "#{result}(#{I18n.t('agent.state_0')})"
  end

  def ok?
    self.state == STATE_OK
  end

  def disabled_eom?
    self.state == STATE_DISABLED_EOM
  end

  def disabled?
    self.state == STATE_DISABLED
  end

  def enable
    extension = nil
    _charge_agent = { charge_id: nil, monthly_rent: 0, minutes: 0, min_fee_balance: 0 }

    self.transaction do
      ChargeAgent.create!(_charge_agent.merge(agent_id: self.id))
      extension = self.create_extension!
      self.update!(show_number: self.company.phone_numbers.agent_numbers.first.number, # TODO: 最好自动选择一个未过期的主叫号码, 除非不存在未过期主叫号码
                   state: Agent::STATE_OK)
    end

    RedisHelp.add_agent(self.company_id, self.code, self.show_number, _charge_agent)
    RedisHelp.add_extension(extension) if extension.present?
  end

  def recover
    recover_agent = RecoverAgent.find_by_agent_id(self.id)
    if recover_agent.present?
      if Time.now - recover_agent.created_at <= 35.days
        if recover_agent.salesman_id.present? && Salesman.find_by_id(recover_agent.salesman_id).try(:active) == true && self.company.agents.where(salesman_id: recover_agent.salesman_id).blank?
          salesman_id = recover_agent.salesman_id
          RedisHelp.set_agent_salesman_id(self.id, salesman_id)
        else
          salesman_id = nil
        end
        if self.company.phone_numbers.agent_numbers.pluck(:number).include?(recover_agent.show_number) && self.show_number != recover_agent.show_number
          show_number = recover_agent.show_number
          RedisHelp.update_agent_show_number(self.id, show_number)
        else
          show_number = self.show_number
        end
        self.update(salesman_id: salesman_id, show_number: show_number)

        if recover_agent.group_id.present?
          group = Group.find_by_id(recover_agent.group_id)
          if group.present?
            AgentsGroups.create(agent_id: self.id, group_id: group.id)
            RedisHelp.set_group(group)
            RedisHelp.group_add_agents(group, [self])
            if group.state == Group::STATE_DELETED
              group.update(state: Group::STATE_OK)
              recover_agent.group_user_ids.to_s.split(',').each do |user_id|
                GroupsUsers.create(group_id: group.id, user_id: user_id) if User.find_by_id(user_id).present?
              end
            end
          end
        end
      end

      RecoverAgent.where(agent_id: self.id).delete_all
    end
  end

  def disable
    RedisHelp.delete_agent(self)

    self.extensions.each { |extension| extension.destroy }
    self.charge_changes.delete_all
    self.charge_agent.try(:destroy)
    self.ags.delete_all
    self.disabled_agents.delete_all
    self.assign_attributes({ state: Agent::STATE_DISABLED,
                             salesman_id: nil,
                             show_number: nil,
                             transfer: false,
                             private_phone: nil,
                             callback_show_original_number: true,
                             extension_type: Agent::EXTENSION_TYPE_SIP })
    self.save(validate: false)
  end

  def create_extension!
    extension = Extension.new(company_id: self.company_id,
                              extension: (self.code - 200).to_s,
                              extension_type: Extension::EXTENSION_TYPE_AGENT,
                              agent_id: self.id)

    count = 0

    # 因为分机号可能会重复，所以当遇到重复的分机号时，就在401到499之间随机分配一个分机号
    until extension.valid? || count > 500
      count = count + 1

      extension.extension = (401..499).to_a.sample.to_s
    end

    extension.save!

    extension
  end

  def update_salesman_id(salesman_id)
    self.update_attributes(salesman_id: salesman_id)
    RedisHelp.set_agent_salesman_id(self.id, salesman_id)
  end

  def phone_number
    self.company.phone_numbers.find_by_number(self.show_number)
  end

  private

  def init
    self.state ||= STATE_OK
    self.extension_type ||= EXTENSION_TYPE_SIP
    self.transfer = false if self.transfer.nil?
    self.callback_show_original_number = true if self.callback_show_original_number.nil?
  end
end
