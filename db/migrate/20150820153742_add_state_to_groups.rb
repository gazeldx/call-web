class AddStateToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :state, :integer, default: 1 # 0: 已删除 1: 正常
  end
end