class AddIndexCalleeNumberToCdrs < ActiveRecord::Migration
  def change
    add_index :cdrs, :callee_number
  end
end