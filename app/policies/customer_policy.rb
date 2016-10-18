class CustomerPolicy
  attr_reader :user, :customer

  def initialize(user, customer)
    @user = user
    @customer = customer
  end

  def popup?
    # 这里我做过一个测试，即先用A企业的Salesman帐号login，打开“消息控制台”后，换B企业Salesman帐号login,是会弹屏的。但弹出的屏对B企业没有价值，所以这里不是一个大问题。
    # 如果要从根本上做好，就是 TODO: 通过faye控制不要弹屏。
    workmate? && @user.class == Salesman
  end

  def manual_create?
    workmate? && @user.company.customers.ok.count <= [Customer::MAX_MANUAL_SAVE_COUNT, @user.company.company_config.import_customers_count].max
  end

  def edit?
    workmate? && (@user.class == User || @customer.salesman == @user)
  end

  def update?
    workmate? # 这里现在不加其他限制，因为弹屏有时候是要在其他销售员那里弹出的，这时虽然不是他的客户，也要允许他更新。
  end

  private

  def workmate?
    @user.company == @customer.company
  end
end