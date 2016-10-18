class HistoryCdr < ActiveRecord::Base
  establish_connection "#{Rails.env}_second"

  include CdrBase

  belongs_to :company
  belongs_to :agent
  belongs_to :task
  belongs_to :salesman
  belongs_to :group
end
