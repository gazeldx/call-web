# 模块：Charge
class CreateChargeCompany400 < ActiveRecord::Migration
  def change
    # 企业400呼入费率表（别名：企业400呼入套餐1）
    #   * 当呼入时，客户听到语音，还没有转座席，已经开始计费。计企业费用，不计座席
    #   * 其它呼入不收费
    create_table :charge_company_400 do |t|
      #t.integer :id #内部id（从4001开始） 注：rails的id是自动创建的
      t.string   :name #名称
      t.float    :price #400呼入单价（单位：元）
      t.timestamps
    end
  end
end
