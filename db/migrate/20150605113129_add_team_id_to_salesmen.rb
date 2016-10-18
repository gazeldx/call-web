class AddTeamIdToSalesmen < ActiveRecord::Migration
  def change
    add_column :salesmen, :team_id, :integer
  end
end