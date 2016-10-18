class AddImportCustomersCountToCompanyConfigs < ActiveRecord::Migration
  def change
    add_column :company_configs, :import_customers_count, :integer # 销售线索（客户）数量上限
  end
end