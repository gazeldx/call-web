class CompanyConfig2Policy < Struct.new(:user, :company_config2)
  attr_reader :user

  def initialize(user, company_config2)
    @user = user
  end

  def popup?
    @user.company.company_config.present? and @user.company.company_config.popup?
  end

  def salesman_can_see_numbers?
    @user.company.company_config.salesman_can_see_numbers?
  end
end