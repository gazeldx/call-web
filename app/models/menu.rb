class Menu < ActiveRecord::Base
  # TODO: Put menu table to Redis?
  # has_and_belongs_to_many :companies

  validates :name, length: { in: 2..50 }, uniqueness: true
end