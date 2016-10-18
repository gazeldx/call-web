class Option < ActiveRecord::Base
  belongs_to :company

  validates :company, presence: true
  validates :tid,     presence: true
  validates_numericality_of :tid,   only_integer: true
  validates_numericality_of :value, only_integer: true
  validates :value, uniqueness: { scope: [:company_id, :tid] }
  validates :text,  uniqueness: { scope: [:company_id, :tid] }
  validates :active, inclusion: { in: [true, false] }

  after_initialize :init

  before_validation :next_value, on: :create

  private

  def init
    self.active = true if self.active.nil?
  end

  def next_value
    self.value = self.company.options.where(tid: self.tid).maximum(:value).to_i + 1
  end
end
