class Point < ActiveRecord::Base
  validates :name, length: { in: 2..50 }, uniqueness: true
end