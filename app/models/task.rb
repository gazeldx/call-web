class Task < ActiveRecord::Base
  STATE_INIT = 9 # STATE具体含义详见 db/migrate/20141111013146_create_tasks.rb
  STATE_READY = 0
  STATE_RUNNING = 1
  STATE_PAUSED = 2
  STATE_FINISHED = 3
  STATE_STASHED = 5

  MAX_TASK_PHONES = 50000

  MAX_PHONE_NUMBERS_KEPT_DAYS = 7

  belongs_to :bundle
  belongs_to :creator, class_name: 'User'
  delegate   :company, to: :bundle

  has_many   :cdrs
  has_many   :task_phones, dependent: :delete_all #http://stackoverflow.com/questions/2797339/rails-dependent-destroy-vs-dependent-delete-all

  scope :running, -> { where(state: STATE_RUNNING) }
  scope :before_running, -> { where(state: [STATE_INIT, STATE_READY, STATE_PAUSED]) }
  scope :running_and_before, -> { where(state: [STATE_INIT, STATE_READY, STATE_PAUSED, STATE_RUNNING]) }

  validates :name, uniqueness: { scope: :bundle_id }, length: { in: 1..50 }
  validates :creator, presence: true
  validates :state, inclusion: { in: [STATE_INIT, STATE_READY, STATE_RUNNING, STATE_PAUSED, STATE_FINISHED, STATE_STASHED] }

  after_initialize :init

  # Dynamic define methods init? ready? running? paused? stashed? finished?
  # Return boolean: self.state == STATE_INIT(or others)
  Task.constants.select{ |c| c.match(/STATE_.*/) }.each do |state|
    define_method("#{state.to_s.downcase.sub('state_', '')}?") { self.state == Task::const_get(state) }
  end

  def remains_count
    self.phone_count - self.executed_count
  end

  def stash
    self.update_attributes(state: STATE_STASHED)
  end

  def resume
    self.transaction do
      self.task_phones.where(phone: (self.task_phones.pluck(:phone) & self.bundle.company.active_tasks_phones)).delete_all # 去掉和现有号码库中重复的号码
      self.update_attributes(state: STATE_PAUSED, phone_count: self.task_phones.count)
      self.bundle.update_attributes(active: true) if self.bundle.active == false
    end
  end

  private

  def init
    self.state ||= STATE_INIT
    self.phone_count ||= 0
    self.executed_count ||= 0
    self.contacted_count ||= 0
    self.answered_count ||= 0
    self.missed_count ||= 0
  end
end
