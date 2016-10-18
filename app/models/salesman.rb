class Salesman < ActiveRecord::Base
  WRONG_PASSWORD_MAX_COUNT = 7
  USER_UNIQUE_PREFIX = "__userId__"

  belongs_to :company
  belongs_to :team

  has_one :agent
  has_many :cdrs
  has_many :history_cdrs
  has_many :customers
  has_many :contacts
  has_many :report_agent_dailies
  has_many :satisfaction_statistics
  has_many :sales_numbers, dependent: :destroy

  scope :active,  -> { where(active: true) }

  validates           :username, uniqueness: true
  validates_length_of :username, within: 4..25
  validates_format_of :username, with: /\A[a-z_0-9]+\z/, message: I18n.t('invalid_format')

  validates_length_of :name, within: 2..30
  validates           :name, uniqueness: { scope: :company_id }
  validates :company, presence: true

  before_create :encrypt_password

  def too_many_wrong_password?
    self.wrong_password_count >= WRONG_PASSWORD_MAX_COUNT
  end

  def increase_wrong_password_count
    self.update(wrong_password_count: self.wrong_password_count + 1)
  end

  def clear_wrong_password_count
    self.update(wrong_password_count: 0)
  end

  def agent_id
    self.try(:agent).try(:id)
  end

  private

  def encrypt_password
    self.passwd = Digest::SHA1.hexdigest(self.passwd)
  end
end
