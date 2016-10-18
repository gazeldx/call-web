class AddTargetToColumns < ActiveRecord::Migration
  def change
    add_column :columns, :target, :integer
  end
end
