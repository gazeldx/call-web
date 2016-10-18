# 模块：基础模块
# 表名：月末将被禁用的座席表
# 描述：座席被“月底禁用”后，将插入本表一条数据，在月底晚间12:00前几分钟进行处理
class CreateDisabledAgents < ActiveRecord::Migration
  def change
    create_table :disabled_agents do |t|
      t.belongs_to  :company, index: true
      t.belongs_to  :agent
      t.timestamps
    end

    # add_column :disabled_agents, :processed, :boolean, default: false # false:未处理 true:已处理
  end
end
