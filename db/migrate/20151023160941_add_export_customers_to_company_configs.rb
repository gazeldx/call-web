class AddExportCustomersToCompanyConfigs < ActiveRecord::Migration
  def change
    add_column :company_configs, :export_customers, :boolean, default: false #导入客户信息{true: 可以导, false: 不可以导}
  end
end