class AddActiveToAdministrators < ActiveRecord::Migration
  def change
    add_column :administrators, :active, :boolean, default: true # {true: 启用, false: 停用}
  end
end