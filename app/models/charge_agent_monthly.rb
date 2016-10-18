class ChargeAgentMonthly < ActiveRecord::Base
  self.table_name = 'charge_agent_monthly'

  KIND_MANUAL = 0
  KIND_TASK = 1
  KIND_MANUAL_AND_TASK = 2

  validates :id, uniqueness: true, numericality: { greater_than_or_equal_to: 3001, less_than: 4000, only_integer: true }
  validates :fee, numericality: { greater_than_or_equal_to: 0 }
end
