class ChargeChange < ActiveRecord::Base
  belongs_to :company
  belongs_to :agent
  belongs_to :operator, class_name: 'Administrator'

  validates :company, presence: true
  validates :min_fee, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :not_processed, -> { where(processed: nil) }
end
