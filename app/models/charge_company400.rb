class ChargeCompany400 < ActiveRecord::Base
  self.table_name = 'charge_company_400'

  validates :id, uniqueness: true, numericality: { greater_than_or_equal_to: 4001, less_than: 5000, only_integer: true }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end
