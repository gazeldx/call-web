class AdministratorsPoints < ActiveRecord::Base
  belongs_to :administrator
  belongs_to :point

  validates :administrator, presence: true
  validates :point, presence: true
end
