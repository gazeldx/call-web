class AddGroupIdToCdrs < ActiveRecord::Migration
  def change
    add_column :cdrs, :group_id, :integer # 目前仅用于记录呼入时所转到的队列id
  end
end