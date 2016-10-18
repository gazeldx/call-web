class CompanyConfig < ActiveRecord::Base
  IMPORT_CUSTOMERS_COUNT_LEVEL_1 = 30000
  IMPORT_CUSTOMERS_COUNT_LEVEL_2 = 100000
  IMPORT_CUSTOMERS_COUNT_LEVEL_3 = 200000
  IMPORT_CUSTOMERS_COUNT_LEVEL_4 = 400000

  RECORD_KEPT_MONTHS_1 = 3
  RECORD_KEPT_MONTHS_2 = 6

  mount_uploader :logo, LogoUploader

  belongs_to :company

  validates :web_name, length: { in: 0..255, message: I18n.t('errors.messages.too_long') }
  validates :login_title_first, length: { in: 0..255, message: I18n.t('errors.messages.too_long') }
  validates :login_title_second, length: { in: 0..255, message: I18n.t('errors.messages.too_long') }

  before_validation :set_default_values

  private

  def set_default_values
    self.web_name ||= I18n.t('company_config.default_web_name')
    self.login_title_first ||= I18n.t('company_config.default_login_title_first')
    self.login_title_second ||= I18n.t('company_config.default_login_title_second')
  end
end
