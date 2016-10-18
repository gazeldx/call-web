class AddIndexAtSalesmanIdInCustomers < ActiveRecord::Migration
  def change
    add_index :customers, :salesman_id
  end
end