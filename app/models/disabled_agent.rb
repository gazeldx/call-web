class DisabledAgent < ActiveRecord::Base
  belongs_to :company
  belongs_to :agent
end
