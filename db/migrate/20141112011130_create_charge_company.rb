# 模块：Charge
class CreateChargeCompany < ActiveRecord::Migration
  def change
    # 企业计费配置
    create_table :charge_company do |t|
      t.belongs_to  :company, index: true
      t.integer     :kind #租户座席类型（0:包月 1:流量 2:包月+流量）如果座席没有选套餐则走企业基本设置。有包月则该企业座席可设置包月套餐，有流量则该企业座席可设置流量套餐，都有则都可以设置。
      t.float       :balance #余额
      # t.float       :credit_line #信用额度
      t.belongs_to  :charge_company_outbound #‘企业呼出套餐’id
      t.float       :outbound_min_fee #呼出保底
      t.float       :outbound_min_fee_balance #TODO: 这个暂时不用了，择机删除掉。呼出保底冻结余额（这是配合:outbound_min_fee的字段，月初初始化为[呼出保底:outbound_min_fee]的值）
      t.belongs_to  :charge_company_400 #‘企业400呼入费率表’id（即‘企业400呼入套餐1’）
      t.float       :min_fee_400 #400保底
      t.float       :min_fee_400_balance #TODO: 这个暂时不用了，择机删除掉。400保底冻结余额（月初初始化为[:min_fee_400]的值，每次400呼入时减去(charge_company_400.price * 时长)，减到0后减[:balance]值）
      t.integer     :charge_company_400_month_id # ‘企业400呼入包月套餐’id（有‘企业400呼入包月套餐’则不用‘企业400呼入套餐1’，‘400保底冻结余额’同样失效）
      t.date        :effective_date_400 #‘企业400呼入包月套餐’生效日期
      t.timestamps
    end

    # add_column :charge_company, :number_fee, :float # 码号月租费
    # add_column :charge_company, :charge_mode, :integer, default: 0 # 计费模式（0:座席级 1:企业级，二者的区别是“企业级”的呼出保底必填）
  end
end
