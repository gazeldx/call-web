# 企业充值记录
class RechargePolicy
  attr_reader :user, :recharge

  def initialize(user, recharge)
    @user = user
    @recharge = recharge
  end

  def create?
    @user.is_a?(Administrator) && @recharge.company.charge_company.present? \
      && !positiveBecomeNegative?
  end

  private

  def positiveBecomeNegative?
    @recharge.company.charge_company.balance.to_f >= 0 && (@recharge.amount + @recharge.company.charge_company.balance.to_f < 0)
  end
end