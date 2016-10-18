# 模块：Charge
# 表名：座席包月表
# 描述：座席呼出套餐，别名：座席包月套餐
class CreateChargeAgentMonthly < ActiveRecord::Migration
  def change
    create_table :charge_agent_monthly do |t|
      #t.integer :id #内部id（3001开始） 注：rails的id是自动创建的
      t.string   :name #名称
      t.float    :fee #资费/座席
      t.timestamps
    end

    # add_column :charge_agent_monthly, :kind, :integer # {0:手拔, 1:预测, 2:手拔+预测}
  end
end
