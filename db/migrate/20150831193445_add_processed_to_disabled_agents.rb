class AddProcessedToDisabledAgents < ActiveRecord::Migration
  def change
    add_column :disabled_agents, :processed, :boolean, default: false # false:未处理 true:已处理
  end
end