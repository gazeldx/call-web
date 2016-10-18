class AddCreatedAtToOptions < ActiveRecord::Migration
  def change
    add_column :options, :created_at, :timestamp
  end
end
