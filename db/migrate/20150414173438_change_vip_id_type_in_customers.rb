# 这个文件是解决production产品服务器上vip_id是boolean的临时问题
class ChangeVipIdTypeInCustomers < ActiveRecord::Migration
  def up
    change_column :customers, :vip_id, 'integer USING CAST(vip_id AS integer)'
  end

  def down
    # Do nothing.
  end
end