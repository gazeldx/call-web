class Team < ActiveRecord::Base
  belongs_to :company

  has_and_belongs_to_many :users
  has_many :salesmen

  validates :name, uniqueness: { scope: :company_id }, length: { in: 1..20 }
  validates :company, presence: true
end
