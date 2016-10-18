class SalesNumber < ActiveRecord::Base
  belongs_to :salesman

  validates :salesman, presence: true
  validates :show_number, presence: true
end
