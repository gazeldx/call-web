# 模块：Charge
# 表名：超出上限不计费表
# 描述：座席呼出套餐，属于按流量计费，别名：座席套餐2
class CreateChargeAgentExceedFree < ActiveRecord::Migration
  def change
    create_table :charge_agent_exceed_free do |t|
      #t.integer :id #内部id（2001开始） 注：rails的id是自动创建的
      t.string   :name #名称
      t.float    :max_fee #上限费用
      t.float    :min_fee #保底
      t.float    :price #单价（单位：元）
      t.timestamps
    end

    # add_column :charge_agent_exceed_free, :kind, :integer # {0:手拔, 1:预测, 2:手拔+预测}
  end
end
