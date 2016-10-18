class AddSalesmanCanSeeNumbersToCompanyConfigs < ActiveRecord::Migration
  def change
    add_column :company_configs, :salesman_can_see_numbers, :boolean, default: true #销售员登录后是否可以看见客户号码
  end
end