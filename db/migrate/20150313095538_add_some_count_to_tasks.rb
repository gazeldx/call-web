class AddSomeCountToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :answered_count, :integer #应答数量
    add_column :tasks, :missed_count, :integer #呼损数量
  end
end
