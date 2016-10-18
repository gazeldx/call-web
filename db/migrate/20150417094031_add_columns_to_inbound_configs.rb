class AddColumnsToInboundConfigs < ActiveRecord::Migration
  def change
    add_column :inbound_configs, :has_rate, :integer, default: 0 # 呼入设置是否开启 服务评价， 1-开启
    add_column :inbound_configs, :rate_id, :integer  # 服务评价记录id
  end
end
