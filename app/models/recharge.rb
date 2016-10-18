class Recharge < ActiveRecord::Base
  belongs_to :company
  belongs_to :operator, class_name: 'Administrator'

  validates :company, presence: true
  validates :remark, length: { maximum: 255 }
end
