class AddSwitchSalesmanToCompanyConfigs < ActiveRecord::Migration
  def change
    add_column :company_configs, :switch_salesman, :boolean, default: false # 弹屏后点击保存时, 销售员是否更新成当前销售员?{false: '不更新', true: '更新'}(如果客户没有销售员跟, 无论本值, 都会更新销售员; 如果客户已经有销售员跟了, 本值会起作用。)
  end
end