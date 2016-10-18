# 模块：Charge
# 表名：共享保底套餐表
# 描述：所有设置了本表套餐的座席的保底是共享的，所有保底值加总到一个总保底中。
#      只要总保底值大于0，设置了本表套餐的座席计费就会优先消费总保底，消费完了总保底，消费 :charge_company 的balance。
#      座席呼出套餐，属于按流量计费，别名：座席套餐4
class CreateChargeAgentShareMinfee < ActiveRecord::Migration
  def change
    create_table :charge_agent_share_minfee do |t|
      #t.integer :id # 内部id（7001开始） 注：rails的id是自动创建的
      t.string   :name # 名称
      t.float    :min_fee # 保底
      t.float    :price # 单价（单位：元）
      t.integer  :kind # {0:手拔, 1:预测, 2:手拔+预测}
      t.timestamps
    end
  end
end
