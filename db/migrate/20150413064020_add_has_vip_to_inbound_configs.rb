class AddHasVipToInboundConfigs < ActiveRecord::Migration
  def change
    add_column :inbound_configs, :has_vip, :integer, default: 0 # 呼入设置是否开启vip呼入特权， 1-开启
  end
end
