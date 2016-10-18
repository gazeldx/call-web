class AddMoreColumnsToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :s21, :string
    add_column :customers, :s22, :string
    add_column :customers, :s23, :string
    add_column :customers, :s24, :string
    add_column :customers, :s25, :string
    add_column :customers, :s26, :string
    add_column :customers, :s27, :string
    add_column :customers, :s28, :string
    add_column :customers, :s29, :string
    add_column :customers, :s30, :string
    add_column :customers, :t10, :string
    add_column :customers, :t11, :string
    add_column :customers, :t12, :string
    add_column :customers, :t13, :string
    add_column :customers, :t14, :string
    add_column :customers, :t15, :string
  end
end