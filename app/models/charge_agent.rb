class ChargeAgent < ActiveRecord::Base
  self.table_name = 'charge_agent'

  belongs_to :agent

  validates :agent, presence: true, uniqueness: true
  validates :monthly_rent, numericality: { greater_than_or_equal_to: 0 }, presence: true


  def self.manual_charge_ids
    ChargeAgentMinutely.where(kind: ChargeAgentMinutely::KIND_MANUAL).pluck(:id) \
      + ChargeAgentExceedFree.where(kind: ChargeAgentExceedFree::KIND_MANUAL).pluck(:id) \
      + ChargeAgentShareMinfee.where(kind: ChargeAgentShareMinfee::KIND_MANUAL).pluck(:id) \
      + ChargeAgentMonthly.where(kind: ChargeAgentMonthly::KIND_MANUAL).pluck(:id)
  end

  def self.get_class_name_by_charge_id(charge_id)
    clazz = nil

    if charge_id.to_s.start_with?('1')
      clazz = ChargeAgentMinutely
    elsif charge_id.to_s.start_with?('2')
      clazz = ChargeAgentExceedFree
    elsif charge_id.to_s.start_with?('3')
      clazz = ChargeAgentMonthly
    elsif charge_id.to_s.start_with?('7')
      clazz = ChargeAgentShareMinfee
    end

    clazz
  end

  def self.charge_fee(charge_id, company_id)
    clazz = self.get_class_name_by_charge_id(charge_id)
    charge = clazz.find(charge_id)
    fee = if clazz == ChargeAgentMinutely
            charge.fee * DateTime.left_days_this_month_ratio
          elsif clazz == ChargeAgentExceedFree
            charge.min_fee
          elsif clazz == ChargeAgentShareMinfee
            if Time.now.hour >= 14 # 下午2:00后，当日保底不计
              charge.min_fee * DateTime.left_days_this_month_ratio
            else
              charge.min_fee * DateTime.days_include_today_remain_current_month_ratio
            end
          elsif clazz ==  ChargeAgentMonthly
            if Time.now - Company.find(company_id).created_at < 30.days || Time.now.hour >= 14 # 一个月内开户的新企业或者下午2:00后，当日包月免费
              charge.fee * DateTime.left_days_this_month_ratio
            else
              charge.fee * DateTime.days_include_today_remain_current_month_ratio
            end
          end
    fee
  end

  def charge_name
    unless self.charge_id.nil?
      clazz = ChargeAgent.get_class_name_by_charge_id(self.charge_id)

      clazz.find(self.charge_id).try(:name) || self.charge_id
    end
  end

  def charge_kind_show
    unless self.charge_id.nil?
      clazz = ChargeAgent.get_class_name_by_charge_id(self.charge_id)

      '(' + I18n.t("charge_agent_monthly.kind_#{clazz.find(self.charge_id).try(:kind)}") + ')'
    end
  end

  def create_charge!(charge_agent_params)
    charge_company = self.agent.company.charge_company
    company_balance = charge_company.balance

    monthly_rent_this_month = 0
    if should_charge_monthly_rent?(charge_agent_params[:monthly_rent].to_f)
      monthly_rent_this_month = charge_agent_params[:monthly_rent].to_f * DateTime.left_days_this_month_ratio
    end

    self.monthly_rent = charge_agent_params[:monthly_rent].to_f
    self.charge_id = charge_agent_params[:charge_id].to_i
    self.minutes = 0
    self.min_fee_balance = 0

    charge_fee = ChargeAgent.charge_fee(self.charge_id, self.agent.company_id)

    clazz = self.class.get_class_name_by_charge_id(self.charge_id)

    if clazz == ChargeAgentMinutely
      self.minutes = ChargeAgentMinutely.remain_minutes(self.charge_id)
    elsif [ChargeAgentExceedFree, ChargeAgentShareMinfee].include?(clazz)
      self.min_fee_balance = charge_fee
    end

    self.transaction do
      charge_company.balance = charge_company.balance - charge_fee - monthly_rent_this_month
      charge_company.save!

      company_balance = company_balance - charge_fee

      Bill.create!(company_id: self.agent.company.id,
                   agent_id: self.agent_id,
                   fee_type_id: clazz == ChargeAgentExceedFree ? FeeType::ID_FREEZE : FeeType::ID_CHARGE_COMPANY,
                   charge_id: self.charge_id,
                   fee: charge_fee,
                   balance: company_balance,
                   month: Time.now.strftime("%Y%m"))

      if monthly_rent_this_month > 0
        company_balance = company_balance - monthly_rent_this_month

        Bill.create!(company_id: self.agent.company.id,
                     agent_id: self.agent_id,
                     fee_type_id: FeeType::ID_AGENT_RENT,
                     charge_id: nil,
                     fee: monthly_rent_this_month,
                     balance: company_balance,
                     month: Time.now.strftime("%Y%m"))
      end

      self.save!
    end

    RedisHelp.update_charge_agent(self)
    RedisHelp.update_share_fee(self.agent.company.id, charge_fee) if clazz == ChargeAgentShareMinfee
    $redis.set("OUT:#{self.agent_id}", 'Available') if charge_company.charge_company_outbound_id == ChargeCompanyOutbound::TRIAL_ID && $redis.get("OUT:#{self.agent_id}") == 'NotAvailable' # 企业为试用套餐的未设置计费的座席在设置完成计费方案后, 如果为'NotAvailable', 立刻转为'Available'
  end

  def update_monthly_rent!(monthly_rent)
    charge_company = self.agent.company.charge_company

    monthly_rent_this_month = 0
    if should_charge_monthly_rent?(monthly_rent)
      monthly_rent_this_month = monthly_rent * DateTime.left_days_this_month_ratio
    end
    self.monthly_rent = monthly_rent

    self.transaction do
      if monthly_rent_this_month > 0
        charge_company.balance = charge_company.balance - monthly_rent_this_month
        charge_company.save!

        Bill.create!(company_id: self.agent.company.id,
                     agent_id: self.agent_id,
                     fee_type_id: FeeType::ID_AGENT_RENT,
                     charge_id: nil,
                     fee: monthly_rent_this_month,
                     balance: charge_company.balance,
                     month: Time.now.strftime("%Y%m"))
      end

      self.save!
    end

    RedisHelp.update_charge_agent(self) #TODO: 更新月租不应该更新其它数据
  end

  def should_charge_monthly_rent?(monthly_rent)
    self.monthly_rent.to_f == 0 && monthly_rent > 0
  end
end
