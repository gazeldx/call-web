class AddMaxInboundToInboundConfigs < ActiveRecord::Migration
  def change
    add_column :inbound_configs, :max_inbound, :integer
  end
end
