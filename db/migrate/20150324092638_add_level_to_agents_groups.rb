class AddLevelToAgentsGroups < ActiveRecord::Migration
  def change
    add_column :agents_groups, :level, :integer #呼入时座席接听优先级 1:低级别 2:中级别(默认) 3:高级别(优先接听)
  end
end
