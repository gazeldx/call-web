class RecoverAgent < ActiveRecord::Base
  belongs_to :company
  belongs_to :agent
  belongs_to :group
  belongs_to :salesman

  validates :company, presence: true
  validates :agent, presence: true
end
