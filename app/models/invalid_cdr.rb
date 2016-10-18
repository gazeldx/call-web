class InvalidCdr < ActiveRecord::Base
  KINDS = [1, 2, 3, 4, 5, 6]

  belongs_to :company
  belongs_to :task
end
