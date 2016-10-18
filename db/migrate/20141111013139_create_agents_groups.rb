# 模块：基础模块
# 表名：座席与座席组关联表
class CreateAgentsGroups < ActiveRecord::Migration
  def change
    create_table :agents_groups do |t|
      t.belongs_to :agent, index: true
      t.belongs_to :group, index: true
    end

    # add_column :agents_groups, :level, :integer #呼入时座席接听优先级 1:低级别 2:中级别(默认) 3:高级别(优先接听)
  end
end
