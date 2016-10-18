# 模块：Charge
class CreateChargeCompany400Months < ActiveRecord::Migration
  def change
    # 别名：企业400呼入包月套餐，企业400呼入套餐2
    #   * 资费在生效日期扣除
    create_table :charge_company_400_months do |t|
      t.string   :name #名称
      t.float    :fee #资费
      t.integer  :months #有效期（月份数）
      t.integer  :agent_count #送坐席数量（免收月租，即:charge_agent的monthly_rent=0）
      t.timestamps
    end
  end
end
