class CompaniesMenus < ActiveRecord::Base
  belongs_to :company
  belongs_to :menu

  validates :menu_id, uniqueness: { scope: :company_id }
  validates :company, presence: true
  validates :menu, presence: true
end
