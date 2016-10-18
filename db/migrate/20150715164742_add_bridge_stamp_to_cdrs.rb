class AddBridgeStampToCdrs < ActiveRecord::Migration
  def change
    add_column :cdrs, :bridge_stamp, :timestamp # 桥接时间
  end
end