class Customer < ActiveRecord::Base
  MAX_MANUAL_SAVE_COUNT = 100000 # 默认的手动加客户的数量上限(后台如果在"其它设置"中扩容到超过这个值了, 则本值就用不上了)
  MAX_STATE_POPUP_COUNT = 1000000 # 批量导入弹屏用的隐藏的销售线索数的数量级
  MAX_UPDATE_COUNT = 5000

  ACT_BOTH = 0 # TODO: 之后应该去掉, 因为没有这种值了。
  ACT_CUSTOMER = 1
  ACT_CLUE = 2

  STATE_DELETED = 0
  STATE_OK = 1
  STATE_POPUP = 2

  MAX_PACKAGE_RECORDS_CUSTOMERS_COUNT = 200

  MAX_EXPORT_COUNT_ON_BUSY_TIME = 1000 # 工作时间可以导出的客户名单最大数量

  ENCODE_NUMBER_PREFIX = 'pRn' # 隐藏号码销售员弹屏时, 用于指示本URL的号码部分是加密过的。

  belongs_to :company
  belongs_to :salesman
  belongs_to :vip

  has_many :contacts

  scope :ok, -> { where(state: STATE_OK) }
  # scope :company_phones, ->(company_id) { where(company_id: company_id, state: STATE_OK).pluck(:s1) }

  validates :company, presence: true
  validates :s1, uniqueness: { scope: :company_id }, numericality: { greater_than_or_equal_to: 10000001, less_than: 999999999999, only_integer: true }
  validates :s2, presence: true
  (1..Column::MAX_STRING_COUNT).each do |i|
    validates "s#{i}".to_sym, length: { in: 0..255, message: I18n.t('errors.messages.too_long') }, allow_nil: true
  end

  before_create :set_state

  def agent_id
    self.salesman.try(:agent).try(:id)
  end

  def agent
    self.salesman.try(:agent)
  end

  def act_as_customer?
    self.act == ACT_CUSTOMER
  end

  def act_as_clue?
    self.act == ACT_CLUE
  end

  # TODO: 这个需要去掉, 因为没有0值了。
  def act_as_both?
    self.act == ACT_BOTH
  end

  private

  def set_state
    self.state ||= STATE_OK
  end
end
