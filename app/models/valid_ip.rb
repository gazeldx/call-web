class ValidIp < ActiveRecord::Base
  belongs_to :company

  validates :ip, uniqueness: { scope: :company_id }, presence: true # TODO: Ensure it is a real IP.
  validates :company, presence: true
end
