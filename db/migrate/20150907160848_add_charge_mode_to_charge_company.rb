class AddChargeModeToChargeCompany < ActiveRecord::Migration
  def change
    add_column :charge_company, :charge_mode, :integer, default: 0 # 计费模式（0:座席级 1:企业级，二者的区别是“企业级”的呼出保底必填）
  end
end