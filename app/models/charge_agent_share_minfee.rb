class ChargeAgentShareMinfee < ActiveRecord::Base
  self.table_name = 'charge_agent_share_minfee'

  KIND_MANUAL = 0
  KIND_TASK = 1
  KIND_MANUAL_AND_TASK = 2

  validates :id, uniqueness: true, numericality: { greater_than_or_equal_to: 7001, less_than: 8000, only_integer: true }
  validates :min_fee, numericality: { greater_than_or_equal_to: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0, less_than: 0.5 }
end
