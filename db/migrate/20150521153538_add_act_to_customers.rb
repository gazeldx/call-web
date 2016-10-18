class AddActToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :act, :integer
  end
end
