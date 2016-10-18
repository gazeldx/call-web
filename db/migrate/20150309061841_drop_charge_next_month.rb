class DropChargeNextMonth < ActiveRecord::Migration
  def up
    drop_table :charge_next_month
  end

  def down
    create_table :charge_next_month
  end
end
