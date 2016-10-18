class ChangeIndexAsS1ToCustomers < ActiveRecord::Migration
  def up
    remove_index :customers, :t1
    add_index    :customers, :s1
  end

  def down
    add_index    :customers, :t1
    remove_index :customers, :s1
  end
end
