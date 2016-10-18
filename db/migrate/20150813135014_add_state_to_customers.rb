class AddStateToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :state, :integer, default: 1 # 0: 已删除 1: 正常 2: 为弹屏而导入（会被定期清除）
  end
end