class AddTimeoutRepeatToIvrs < ActiveRecord::Migration
  def change
    add_column :ivrs, :timeout_repeat, :integer, :default => 2
  end
end
