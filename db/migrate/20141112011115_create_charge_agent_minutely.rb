# 模块：Charge
# 表名：按分钟数计费表
# 描述：座席呼出套餐，属于按流量计费，别名：座席套餐1
class CreateChargeAgentMinutely < ActiveRecord::Migration
  def change
    create_table :charge_agent_minutely do |t|
      #t.integer :id #内部id（1001开始） 注：rails的id是自动创建的
      t.string   :name #名称
      t.float    :fee #功能费
      t.integer  :minutes #通话分钟数
      t.float    :price #超出单价（单位：元）
      t.timestamps
    end

    # add_column :charge_agent_minutely, :kind, :integer # {0:手拔, 1:预测, 2:手拔+预测}
  end
end
