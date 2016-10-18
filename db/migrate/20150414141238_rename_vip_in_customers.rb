class RenameVipInCustomers < ActiveRecord::Migration
  def change
    rename_column :customers, :vip, :vip_id
  end
end
