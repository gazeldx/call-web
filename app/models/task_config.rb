class TaskConfig < ActiveRecord::Base
  self.table_name = 'company_task_config'

  DEFAULT_LONG_IDLE_TIME = 10
  MIN_LONG_IDLE_TIME = 5
  MAX_LONG_IDLE_TIME = 20

  DEFAULT_PREDICT_MAX_RATIO = 2.5

  belongs_to :company

  validates :long_idle_time, inclusion: MIN_LONG_IDLE_TIME..MAX_LONG_IDLE_TIME
  validates :predict_max_ratio, inclusion: 0.1..6 # TODO: All columns

  after_initialize :init

  private

  def init
    self.long_idle_time ||= DEFAULT_LONG_IDLE_TIME
    self.long_checkin = true if self.long_checkin.nil?
    self.predict_max_ratio ||= DEFAULT_PREDICT_MAX_RATIO
    self.voice_max_ratio ||= 8
    self.voice_max_duration ||= 15
    self.keypress_max_concurrency ||= 100
  end
end
