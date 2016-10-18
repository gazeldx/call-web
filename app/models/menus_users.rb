class MenusUsers < ActiveRecord::Base
  belongs_to :menu
  belongs_to :user

  validates :menu, presence: true
  validates :user, presence: true
end
