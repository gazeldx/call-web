class ChargeCompanyOutbound < ActiveRecord::Base
  self.table_name = 'charge_company_outbound'

  TRIAL_ID = 6100

  validates :id, uniqueness: true, numericality: { greater_than_or_equal_to: 6001, less_than: 7000, only_integer: true }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :transfer_price, numericality: { greater_than_or_equal_to: 0 }
end
