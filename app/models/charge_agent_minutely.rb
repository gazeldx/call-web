class ChargeAgentMinutely < ActiveRecord::Base
  self.table_name = 'charge_agent_minutely'

  KIND_MANUAL = 0
  KIND_TASK = 1
  KIND_MANUAL_AND_TASK = 2

  validates :id, uniqueness: true, numericality: { greater_than_or_equal_to: 1001, less_than: 2000, only_integer: true }
  validates :fee, numericality: { greater_than_or_equal_to: 0 }
  validates :minutes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0, less_than: 0.5 }

  def self.remain_minutes(charge_id)
    (self.find(charge_id).minutes * DateTime.left_days_this_month_ratio).round(0)
  end
end
