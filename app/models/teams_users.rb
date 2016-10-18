class TeamsUsers < ActiveRecord::Base
  belongs_to :team
  belongs_to :user

  validates :team_id, uniqueness: { scope: :user_id }
  validates :team, presence: true
  validates :user, presence: true
end
