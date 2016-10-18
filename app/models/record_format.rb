class RecordFormat < ActiveRecord::Base
  NAMES = ['calleeNumber', 'callerNumber', 'duration', 'agentCode', 'salesmanName', 'date', 'time']

  belongs_to :company

  validates :company, presence: true
  validates :name, presence: true, uniqueness: { scope: :company_id }, inclusion: { in: NAMES }
end