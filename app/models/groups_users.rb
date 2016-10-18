class GroupsUsers < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  validates :group_id, uniqueness: { scope: :user_id }
  validates :group, presence: true
  validates :user, presence: true
end
