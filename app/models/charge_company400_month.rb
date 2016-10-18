class ChargeCompany400Month < ActiveRecord::Base
  self.table_name = 'charge_company_400_months'

  validates :id, uniqueness: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :fee, numericality: { greater_than_or_equal_to: 0 }
  validates :months, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :agent_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
