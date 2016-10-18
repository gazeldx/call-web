class Bundle < ActiveRecord::Base
  KIND_AUTOMATIC = 0
  KIND_PREDICT = 1
  KIND_KEYPRESS_TRANSFER = 2
  KIND_TIMEOUT_TRANSFER = 3
  KIND_KEYPRESS_GATHER = 4
  KIND_IVR = 20 #This is virtual, not saved to database.

  IVR_MENUS = { KIND_KEYPRESS_TRANSFER => 'bundle.keypress_transfer', KIND_TIMEOUT_TRANSFER => 'bundle.timeout_transfer', KIND_KEYPRESS_GATHER => 'bundle.keypress_gather' }

  MAX_RUNNING_TASKS = 10
  MAX_TASKS = 10 # 一个bundle下的在列表页面可显示的号码库数量上限
  MAX_TASKS_FOR_RESUME = 15 # 如果客户点击恢复号码库, 可以允许超过MAX_TASKS个, 上限为本值
  MAX_TASKS_MOST = 20 # 一个bundle下的号码库数量的总上限(含显示的和未显示的)

  DEFAULT_PREDICT_RATIO = 2

  belongs_to :company
  belongs_to :group
  belongs_to :manager, class_name: 'User'
  belongs_to :creator, class_name: 'User'

  has_many :tasks, dependent: :destroy

  scope :count_by_kind, ->(kind = nil) { where(kind: transfered_kind(kind), active: true).count }

  validates :name, uniqueness: { scope: :company_id }, length: { in: 2..30 }
  validates :company, presence: true
  validates :group, presence: true
  validates :creator, presence: true
  validates :ratio, numericality: true
  validates :kind, presence: true, inclusion: { in: [KIND_AUTOMATIC, KIND_PREDICT] + IVR_MENUS.keys }
  validate :number_should_exist_if_predict

  after_initialize :init

  before_save :restrict_values

  def self.transfered_kind(kind)
    if kind == KIND_IVR
      IVR_MENUS.keys
    else
      kind
    end
  end

  # def number_present?
  #   PhoneNumber.find_by_number_and_company_id(self.number, self.company_id).present?
  # end

  def number_are_for_task_if_predict?
    self.number.split(',').each do |number|
      phone_number = PhoneNumber.find_by_number_and_company_id(number, self.company_id)

      return false unless (phone_number.present? && phone_number.for_task?)
    end if self.kind == KIND_PREDICT

    true
  end

  def task_numbers_not_expired_if_predict?
    self.number.split(',').each do |number|
      phone_number = PhoneNumber.find_by_number_and_company_id(number, self.company_id)
      return false unless (phone_number.present? && !phone_number.expired?)
    end if self.kind == KIND_PREDICT

    true
  end

  def agents_number_not_expired_if_automatic?
    self.group.agents.pluck(:show_number).each do |number|
      phone_number = PhoneNumber.find_by_number_and_company_id(number, self.company_id)
      return false unless (phone_number.present? && !phone_number.expired?)
    end if self.kind == KIND_AUTOMATIC

    true
  end

  def ivr?
    IVR_MENUS.keys.include?(self.kind)
  end

  private

  def init
    self.ratio ||= 1 if self.kind == KIND_AUTOMATIC
    self.ratio ||= DEFAULT_PREDICT_RATIO if self.kind == KIND_PREDICT
    self.active = true if self.active.nil?
  end

  def restrict_values
    self.ratio = 1 if self.kind == KIND_AUTOMATIC
    self.ratio = self.company.task_config.predict_max_ratio if self.kind == KIND_PREDICT && self.ratio > self.company.task_config.predict_max_ratio
  end

  def number_should_exist_if_predict
    if self.kind == KIND_PREDICT && self.number.blank?
      errors.add(:number, I18n.t('bundle.number_should_exist_if_predict'))
    end
  end
end
