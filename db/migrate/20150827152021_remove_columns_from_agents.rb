class RemoveColumnsFromAgents < ActiveRecord::Migration
  def change
    remove_column :agents, :extension
    remove_column :agents, :shown_number_id
  end
end