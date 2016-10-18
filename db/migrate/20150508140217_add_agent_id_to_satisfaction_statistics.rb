class AddAgentIdToSatisfactionStatistics < ActiveRecord::Migration
  def change
    add_column :satisfaction_statistics, :agent_id, :integer # 座席id
  end
end

