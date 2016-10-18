# 模块：Charge
class CreateChargeCompanyOutbound < ActiveRecord::Migration
  def change
    # 企业呼出费率表（别名：企业呼出套餐）
    create_table :charge_company_outbound do |t|
      #t.integer :id #内部id（6001开始） 注：rails的id是自动创建的
      t.string   :name #名称
      t.float    :price #呼出的每分钟单价（单位：元）
      t.float    :transfer_price #呼转单价(转私人号码)
      t.timestamps
    end
  end
end
