class AddMoreDatesToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :d4, :date
    add_column :customers, :d5, :date
  end
end