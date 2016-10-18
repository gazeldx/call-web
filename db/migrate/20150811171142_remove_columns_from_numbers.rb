class RemoveColumnsFromNumbers < ActiveRecord::Migration
  def change
    remove_column :numbers, :for_task
    remove_column :numbers, :for_agent
    remove_column :numbers, :inbound
    remove_column :numbers, :used_count
    remove_column :numbers, :from_company
    remove_column :numbers, :expire_date
  end
end