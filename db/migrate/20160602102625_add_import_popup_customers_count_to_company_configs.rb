class AddImportPopupCustomersCountToCompanyConfigs < ActiveRecord::Migration
  def change
    add_column :company_configs, :import_popup_customers_count, :integer # 可导入的隐藏的弹屏用的销售线索数量
  end
end