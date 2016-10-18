class AddActiveToSalesmen < ActiveRecord::Migration
  def change
    add_column :salesmen, :active, :boolean, default: true # {true: 启用, false: 停用}
  end
end