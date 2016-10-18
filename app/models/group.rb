class Group < ActiveRecord::Base
  DEFAULT_MAX_LOOP_TIMES = 2
  DEFAULT_MAX_WAIT_TIME = 30

  STATE_DELETED = 0
  STATE_OK = 1

  belongs_to :company

  has_and_belongs_to_many :users
  has_and_belongs_to_many :agents
  has_many :bundles
  has_many :ags, dependent: :destroy
  has_many :gus, dependent: :destroy

  scope :outbound, -> { where(outbound: true, state: STATE_OK) }
  scope :inbound,  -> { where(outbound: false, state: STATE_OK) }
  scope :state_ok,  -> { where(state: STATE_OK) }

  validates :id, uniqueness: true, numericality: { greater_than_or_equal_to: 100018001, less_than: 999999999, only_integer: true }
  validates :name, uniqueness: { scope: :company_id }, length: { in: 1..20 }
  validates :company, presence: true
  validates :outbound, inclusion: { in: [true, false] }
  validates :agents, length: { minimum: 1, message: I18n.t(:at_least_has_one) } # 这是Rails的一个Bug，因为rails这种情况表现为仅对create的时候有效，而update的时候是无效的。这是不正确的。后来我在update的方法里手动加入了agent_ids是否是blank?的判断了。
  validates :max_wait_time, numericality: { greater_than_or_equal_to: 20, less_than_or_equal_to: 60, only_integer: true }

  before_validation :set_id, on: :create
  after_validation :set_values

  def self.get_name(id)
    group = Group.where(id: id).first
    group.nil? ? "座席组不存在" : group.name
  end

  def running_bundle
    Task.where(bundle_id: self.bundles.pluck(:id)).where(state: Task::STATE_RUNNING).first.try(:bundle)
  end

  def set_default_values(default_values)
    default_values.each do |k, v|
      self.send("#{k}=".to_sym, v) if self.try(k.to_sym).nil?
    end
  end

  def cannot_destroy_reason
    error_prefix = "删除座席组“#{self.name}”(#{self.id})的操作被系统拒绝，原因是"
    return "#{error_prefix}#{I18n.t('group.has_running_task')}" if self.running_bundle.present?
    return "#{error_prefix}座席“#{RedisHelp.busy_agents(self, self.agents)[0].code}”正处于通话忙碌状态，此时不可以删除座席组。”" if RedisHelp.busy_agents(self, self.agents).present?
    return "#{error_prefix}“IVR节点中存在转到本组的节点”。请删除相关节点后再进行操作。" if !self.outbound? and Node.exists?(action: 'Trans_Group', value: "#{self.id}")
    return "#{error_prefix}“分机设置中存在转到本组的分机”。请删除相关分机后再进行操作。" if !self.outbound? and ExtensionConfig.exists?(group_id: self.id)
    nil
  end

  # TODO: 这个method name名字和rails默认的destroy同名了, 不太好, 可能引起不必要的误会。最好换个名字
  def destroy
    RedisHelp.remove_group(self)

    self.ags.delete_all
    self.gus.delete_all
    self.update_attribute(:state, Group::STATE_DELETED)
  end

  private

  def set_id
    self.id = self.company.groups.maximum(:id).nil? ? "#{self.company.id}8001" : self.company.groups.maximum(:id) + 1
  end

  def set_values
    if self.outbound?
      self.spill = false
      self.timeout = false
    end

    clear_spill unless self.spill?

    clear_timeout unless self.timeout?
  end

  def clear_spill
    self.spill_count = nil
    self.play_spill_voice = false
    self.spill_ivr_id = nil
  end

  def clear_timeout
    self.play_timeout_voice = false
    self.max_loop_times = nil
    self.timeout_ivr_id = nil
  end
end
