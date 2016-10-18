class Company < ActiveRecord::Base
  # include Redis::Objects
  STATE_OK = 1
  STATE_APPLY_FOR_VACUUM = 2
  STATE_APPLY_FOR_VACUUM_VERIFIED = 3
  STATES = [STATE_OK, STATE_APPLY_FOR_VACUUM, STATE_APPLY_FOR_VACUUM_VERIFIED]

  CAN_VACUUM_HOURS_AFTER_VERIFIED = 1

  DEFAULT_COMPANY_ID = 10000
  BANK_UNION_DATA_IDS = [60315, 60716, 60717]

  BATCH_MIXIN_RECORD_MAX_TIMES_EVERYDAY = RecordPackage::MAX_TIMES_EVERYDAY * 2

  belongs_to :manual_call_vos, class_name: 'ServerIp', foreign_key: 'manual_call_vos_id'
  belongs_to :callback_vos, class_name: 'ServerIp', foreign_key: 'callback_vos_id'
  belongs_to :task_vos, class_name: 'ServerIp', foreign_key: 'task_vos_id'

  # TODO: 可以清理掉，用nbms API了
  belongs_to :helper, class_name: 'Administrator', foreign_key: 'helper_id'
  belongs_to :technician, class_name: 'Administrator', foreign_key: 'technician_id'
  belongs_to :seller, class_name: 'Administrator', foreign_key: 'seller_id'

  has_and_belongs_to_many :menus
  has_many :companymenus, dependent: :destroy
  has_one :company_config
  has_many :users, dependent: :destroy
  has_many :agents, dependent: :destroy
  has_many :groups, dependent: :destroy
  has_many :bundles, dependent: :destroy
  has_one :task_config
  has_many :teams, dependent: :destroy
  has_many :salesmen, dependent: :destroy
  has_many :disabled_agents, dependent: :destroy

  has_many :voices, dependent: :destroy
  has_many :ivrs, dependent: :destroy
  has_many :inbound_configs, dependent: :destroy
  has_many :extension_configs, dependent: :destroy
  has_many :strategies, dependent: :destroy
  has_many :vips, dependent: :destroy
  has_many :satisfaction_statistics, dependent: :destroy

  has_many :numbers
  has_many :phone_numbers, dependent: :destroy

  has_many :cdrs, dependent: :destroy
  has_many :history_cdrs
  has_many :invalid_cdrs, dependent: :destroy

  has_many :record_packages, dependent: :destroy
  has_many :record_formats, dependent: :destroy

  has_many :valid_ips, dependent: :destroy

  has_many :columns, dependent: :destroy
  has_many :options, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :contacts, dependent: :destroy

  has_one :charge_company
  has_many :charge_changes, dependent: :destroy
  has_many :bills, dependent: :destroy
  has_many :recharges, dependent: :destroy

  has_many :report_agent_dailies, dependent: :destroy

  has_many :issues, dependent: :destroy

  attr_accessor :bundle_kind

  validates :id, uniqueness: true, numericality: { greater_than_or_equal_to: 10001, less_than: 99999, only_integer: true }
  validates_length_of :name, within: 2..60
  validates_uniqueness_of :name
  validates_numericality_of :license, only_integer: true
  validates :license, inclusion: 0..999, numericality: { greater_than_or_equal_to: 0, less_than: 999, only_integer: true }, on: :update
  # validates :active, inclusion: { in: [true, false] }
  validates :manual_call_vos_id, presence: true
  validates :callback_vos_id, presence: true
  validates :task_vos_id, presence: true

  after_initialize :init

  self.per_page = 10

  # def phone_numbers
  #   PhoneNumber.where(company_id: self.id)
  # end

  def create_with_relations!(menus)
    self.transaction do
      self.save!

      save_company_menus(menus)

      self.users.create!(name: I18n.t(:user_),
                         username: "u#{self.id}",
                         passwd: '12345678')

      save_default_columns
    end

    RedisHelp.set_company_voses({ company_id: self.id,
                                  manualcall_trunk_ip: self.manual_call_vos.internal_ip,
                                  manualcall_trunk_port: self.manual_call_vos.port,
                                  manualcall_prefix: self.manual_call_prefix,
                                  callback_trunk_ip: self.callback_vos.internal_ip,
                                  callback_trunk_port: self.callback_vos.port,
                                  callback_prefix: self.callback_prefix,
                                  task_trunk_ip: self.task_vos.internal_ip,
                                  task_trunk_port: self.task_vos.port,
                                  task_prefix: self.task_prefix })
  end

  def update_vos_config(company_params)
    if self.update(company_params)
      RedisHelp.set_company_voses({ company_id: self.id,
                                    manualcall_trunk_ip: self.manual_call_vos.internal_ip,
                                    manualcall_trunk_port: self.manual_call_vos.port,
                                    manualcall_prefix: self.manual_call_prefix,
                                    callback_trunk_ip: self.callback_vos.internal_ip,
                                    callback_trunk_port: self.callback_vos.port,
                                    callback_prefix: self.callback_prefix,
                                    task_trunk_ip: self.task_vos.internal_ip,
                                    task_trunk_port: self.task_vos.port,
                                    task_prefix: self.task_prefix })
    end
  end

  def update_menus(menus)
    self.transaction do
      self.menus.delete_all

      # 这里不需要删除该企业的menus_users表中的数据，因为在user.rb中limited_menus和have_menu?已经做好了限制。好处是如果UC管理员误授权功能后，不至于企业要为自己的管理员再补上被误删除的功能菜单

      save_company_menus(menus)
    end
  end

  def update_balance(recharge)
    should_update_available = false

    balance_after_recharge = self.charge_company.balance.to_f + recharge.amount

    self.transaction do
      should_update_available = true if (self.charge_company.balance.to_f <= 0 && balance_after_recharge > 0)

      self.charge_company.balance = balance_after_recharge
      self.charge_company.save!

      recharge.balance = self.charge_company.balance
      recharge.save!
    end

    if should_update_available
      RedisHelp.update_as_available(self)
      RedisHelp.handle_share_minfee(self)
    end
  end

  def admin
    self.users.order(:id).first
  end

  def batch_create_agents!(agent_code_start, agent_count, show_number, charge)
    $redis.get('just:for:test') # 确定Redis是开着的，这样数据才能统一

    clazz = nil
    extensions_created = []
    charge_agents_created = []
    company_balance = self.charge_company.balance
    charge_fee = 0
    _charge_agent = { charge_id: charge[:charge_id].to_i > 0 ? charge[:charge_id].to_i : nil,
                      monthly_rent: charge[:monthly_rent].to_f,
                      minutes: 0,
                      min_fee_balance: 0 }

    if charge[:charge_id].to_i > 0
      charge_fee = ChargeAgent.charge_fee(charge[:charge_id], self.id)
      clazz = ChargeAgent.get_class_name_by_charge_id(charge[:charge_id])
      if clazz == ChargeAgentMinutely
        _charge_agent[:minutes] = ChargeAgentMinutely.remain_minutes(charge[:charge_id])
      elsif [ChargeAgentExceedFree, ChargeAgentShareMinfee].include?(clazz)
        _charge_agent[:min_fee_balance] = charge_fee
      end
    end

    self.transaction do
      agent_count.times do |i|
        agent_id = "#{self.id}#{agent_code_start + i}".to_i
        agent = self.agents.create!(id: agent_id,
                                    code: agent_code_start + i,
                                    show_number: show_number)

        charge_agents_created << ChargeAgent.create!(_charge_agent.merge(agent_id: agent.id))

        extensions_created << agent.create_extension!
      end

      self.charge_company.balance = self.charge_company.balance - charge[:fee_for_batch_create_agents].to_f
      self.charge_company.save!

      self.license += agent_count
      self.save!
    end

    agent_count.times do |i|
      RedisHelp.add_agent(self.id, agent_code_start + i, show_number, _charge_agent)
    end

    extensions_created.each do |extension|
      RedisHelp.add_extension(extension)
    end

    charge_agents_created.each do |charge_agent|
      if charge_agent.charge_id.to_i > 0
        company_balance = company_balance - charge_fee

        Bill.create!(company_id: self.id,
                     agent_id: charge_agent.agent_id,
                     fee_type_id: clazz == ChargeAgentExceedFree ? FeeType::ID_FREEZE : FeeType::ID_CHARGE_COMPANY,
                     charge_id: charge_agent.charge_id,
                     fee: charge_fee,
                     balance: company_balance,
                     month: Time.now.strftime("%Y%m"))
      end

      if charge_agent.monthly_rent > 0
        monthly_rent_this_month =  charge_agent.monthly_rent * DateTime.left_days_this_month_ratio

        company_balance = company_balance - monthly_rent_this_month

        Bill.create!(company_id: self.id,
                     agent_id: charge_agent.agent_id,
                     fee_type_id: FeeType::ID_AGENT_RENT,
                     charge_id: nil,
                     fee: monthly_rent_this_month,
                     balance: company_balance,
                     month: Time.now.strftime("%Y%m"))
      end
    end
  end

  def outbound_groups
    self.groups.outbound.order('created_at')
  end

  def active_tasks_phones
    active_task_ids = Task.where(bundle_id: self.bundles.pluck(:id), state: [Task::STATE_INIT, Task::STATE_READY, Task::STATE_RUNNING, Task::STATE_PAUSED]).pluck(:id)
    TaskPhone.where(task_id: active_task_ids).pluck(:phone)
  end

  def have_menu?(menu_name)
    self.menus.map(&:name).include?(menu_name)
  end

  def name_and_id
    "#{self.id} #{self.name}"
  end

  def vacuum
    self.bills.delete_all
    self.cdrs.delete_all

    self.agents.each { |agent| agent.disable unless agent.disabled? }
    self.agents.delete_all

    self.charge_changes.delete_all # 删除了两遍, 之前在agent.disable时删除过一遍
    self.charge_company.destroy
    RedisHelp.del_inbound_company(self.id)

    self.companymenus.delete_all
    self.task_config.delete
    self.contacts.delete_all
    self.customers.delete_all
    self.columns.delete_all
    self.disabled_agents.delete_all # 删除了两遍, 之前在agent.disable时删除过一遍

    self.invalid_cdrs.delete_all
    self.issues.destroy_all

    self.groups.each { |group| group.destroy }
    self.groups.delete_all

    self.options.delete_all
    self.recharges.delete_all
    self.record_formats.delete_all
    self.record_packages.delete_all
    self.report_agent_dailies.delete_all

    tasks = Task.where(bundle_id: self.bundles.pluck(:id))
    TaskPhone.where(task_id: tasks.pluck(:id)).delete_all
    tasks.delete_all
    self.bundles.delete_all

    self.teams.destroy_all
    self.salesmen.each { |salesman| salesman.sales_numbers.delete_all }
    self.salesmen.delete_all

    self.users.where('name <> ?', I18n.t(:user_)).destroy_all
    self.valid_ips.delete_all

    self.strategies.each do |strategy|
      strategy.implode
      RedisHelp.del_strategy_list(strategy.group_id)
    end

    self.extension_configs.each { |extension_config| extension_config.implode } # 删除了两遍, 之前在agent.disable时删除过一遍

    self.ivrs.each do |ivr|
      if ivr.ivr_type == Ivr::TYPE_COLOR_RING
        ivr.color_ring_implode
      else
        ivr.implode
      end
    end

    self.vips.each { |vip| vip.implode }
    self.inbound_configs.each { |inbound_config| inbound_config.implode }
    self.voices.each { |voice| voice.implode }
    self.satisfaction_statistics.delete_all

    self.numbers.update_all(company_id: nil)
    self.phone_numbers.each { |phone_number| phone_number.implode }
    self.company_config.delete

    HistoryCdr2.where(company_id: self.id).delete_all

    # RedisHelp.del_company_vos_configs(self.id) # 不清理xx_vos_id, 只清理xx_prefix
    self.admin.update_attributes(username: "u#{self.id}", passwd: '12345678')
    save_default_columns
    self.update!(state: Company::STATE_OK,
                 name: "#{self.id}是#{I18n.t('company.name_ready')}",
                 license: 0,
                 mobile: nil,
                 created_at: Time.now + 3.years,
                 manual_call_prefix: nil, # 不清理xx_vos_id, 只清理xx_prefix, 虽然导致pg和redis不同步, 不过由于prefix和线路在企业启用时会被修改, 也就不是什么问题了。
                 callback_prefix: nil,
                 task_prefix: nil)
  end

  def vacuum_uploaded_files
    if self.id >= 10000 # Notice: 确认下企业编号合法, 防止误删除父目录, 导致文件丢失
      return system("rm -rf #{Settings.nfs_base_path}/upload_images/#{self.id}; rm -rf #{Settings.nfs_base_path}/voice/#{self.id}; ")
    else
      return false
    end
  end

  def can_charge_change_agent_ids
    ChargeAgent.where(agent_id: self.agents.ok.pluck(:id)).order(:agent_id).pluck(:agent_id) - self.charge_changes.where('agent_id > 0').where(effective_at: Date.today.at_beginning_of_month.next_month).pluck(:agent_id)
  end

  private

  # http://stackoverflow.com/questions/328525/how-can-i-set-default-values-in-activerecord
  def init
    # self.active = true if self.active.nil? # :active字段已经从数据库表中去掉了
    self.state ||= STATE_OK
    self.license ||= 0
  end

  def save_company_menus(menus)
    menus.each do |menu_name|
      self.menus << Menu.find_by_name(menu_name)
    end
  end

  def save_default_columns
    self.columns.create!(name: 's1', title: I18n.t(:mobile), target: Column::TARGET_BOTH)
    self.columns.create!(name: 's2', title: I18n.t(:name), target: Column::TARGET_BOTH)
    self.columns.create!(name: 's3', title: I18n.t(:remark), target: Column::TARGET_BOTH)
  end
end
