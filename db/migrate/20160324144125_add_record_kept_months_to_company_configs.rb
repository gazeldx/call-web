class AddRecordKeptMonthsToCompanyConfigs < ActiveRecord::Migration
  def change
    add_column :company_configs, :record_kept_months, :integer, {null: false, default: 3} # 录音被保存的月份数。过期后将被自动删除
  end
end