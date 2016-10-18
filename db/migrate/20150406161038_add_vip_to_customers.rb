class AddVipToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :vip, :integer # default: 1
  end
end
