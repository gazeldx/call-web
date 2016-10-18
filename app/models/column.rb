class Column < ActiveRecord::Base
  TARGET_BOTH = 0
  TARGET_CUSTOMER = 1
  TARGET_CLUE = 2

  MAX_WIDTH = 4

  MAX_STRING_COUNT = 30
  MAX_ENUM_COUNT = 15
  MAX_DATE_COUNT = 5
  MAX_DATETIME_COUNT = 2

  belongs_to :company

  scope :active, -> { where(active: true) }

  validates :company, presence: true
  validates :name, presence: true, uniqueness: { scope: :company_id }
  validates :title, presence: true, uniqueness: { scope: :company_id }
  validates_numericality_of :width, only_integer: true
  validates :active, inclusion: { in: [true, false] }
  validates :width, inclusion: { in: [1, 2, 3, 4] }
  validates :target, inclusion: { in: [TARGET_BOTH, TARGET_CUSTOMER, TARGET_CLUE] }

  after_initialize :init

  before_save :restrict_width

  def self.new_type_id(type, company)
    column_names = company.columns.where("name LIKE ?", "#{type}%").map { |column| column.name.gsub(/[^0-9]/, '').to_i }
    column_names.blank? ? 1 : column_names.max + 1
  end

  def select?
    self.name.start_with?('t')
  end

  def text?
    self.name.start_with?('s')
  end

  def date?
    self.name.start_with?('d')
  end

  def options
    self.company.options.where(tid: self.name.sub('t', '').to_i)
  end

  private

  def init
    self.active = true if self.active.nil?
    self.width ||= 1
  end

  def restrict_width
    self.width = 1 if !self.text? && self.width != 1
    self.width = MAX_WIDTH if self.width > MAX_WIDTH
  end
end
