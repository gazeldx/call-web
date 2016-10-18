class AddCostToReportAgentDailies < ActiveRecord::Migration
  def change
    add_column :report_agent_dailies, :cost, :float, default: 0 #费用
  end
end