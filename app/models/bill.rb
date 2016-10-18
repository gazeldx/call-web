class Bill < ActiveRecord::Base
  belongs_to :company
  belongs_to :agent
  belongs_to :fee_type
end
