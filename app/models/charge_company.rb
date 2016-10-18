class ChargeCompany < ActiveRecord::Base
  self.table_name = 'charge_company'

  KIND_MONTHLY = 0
  KIND_FLOW = 1
  KIND_BOTH = 2
  CHARGE_MODE_AGENT = 0
  CHARGE_MODE_COMPANY = 1

  OUTBOUND_MIN_FEE_LEAST = 100

  belongs_to :company
  belongs_to :charge_company_outbound
  belongs_to :charge_company400, foreign_key: 'charge_company_400_id'
  belongs_to :charge_company400_month, foreign_key: 'charge_company_400_month_id'

  validates :company, presence: true
  validates :charge_company_outbound, presence: true

  before_save :restrict_values

  def create_and_deduct_fees(_params = {})
    amount = self.balance.to_f

    # 说明：呼出保底开户当月不扣也不冻结，次月开始扣
    self.outbound_min_fee_balance = 0

    if self.number_fee.to_f > 0
      number_fee_bill = Bill.new(company_id: self.company_id, fee_type_id: FeeType::ID_NUMBER_FEE, fee: number_fee_this_month, balance: self.balance.to_f - number_fee_this_month, month: Time.now.strftime("%Y%m"))

      self.balance = self.balance.to_f - number_fee_this_month
    end

    # 说明：呼入保底开户当月不扣也不冻结，次月开始扣
    self.min_fee_400_balance = 0 if charge_company_400_id.to_i > 0

    if self.charge_company_400_month_id.to_i > 0
      fee = ChargeCompany400Month.find(self.charge_company_400_month_id).fee

      charge_company_400_month_bill = Bill.new(company_id: self.company_id, fee_type_id: FeeType::ID_CHARGE_COMPANY, charge_id: self.charge_company_400_month_id, fee: fee, balance: self.balance - fee, month: Time.now.strftime("%Y%m"))

      self.balance = self.balance - fee
    end

    if self.balance <= 0
      return { result: false, message: I18n.t('charge_company.balance_not_enough') }
    else
      self.transaction do
        self.save!

        self.company.recharges.create!(amount: amount, balance: amount, operator_id: _params[:operator_id], remark: I18n.t('recharge.first_time'))

        number_fee_bill.save! if number_fee_bill.present?

        charge_company_400_month_bill.save! if charge_company_400_month_bill.present?
      end

      RedisHelp.initialize_inbound_company(self.company_id)

      return { result: true }
    end
  end

  def balance_shown
    self.balance.try(:round, 2)
  end

  def available_agent_charges
    case self.kind
    when ChargeCompany::KIND_FLOW then return (ChargeAgentExceedFree.all + ChargeAgentMinutely.all + ChargeAgentShareMinfee.all).sort_by(&:id)
    when ChargeCompany::KIND_MONTHLY then return (ChargeAgentMonthly.all).sort_by(&:id)
    when ChargeCompany::KIND_BOTH then return (ChargeAgentMonthly.all + ChargeAgentExceedFree.all + ChargeAgentMinutely.all + ChargeAgentShareMinfee.all).sort_by(&:id)
    end
  end

  private

  def number_fee_this_month
    self.number_fee.to_f * DateTime::left_days_this_month_ratio
  end

  def restrict_values
    self.min_fee_400 = 0 if self.min_fee_400.nil? && self.charge_company_400_id.to_i > 0
    self.effective_date_400 = nil if self.charge_company_400_month_id.nil?
  end
end
