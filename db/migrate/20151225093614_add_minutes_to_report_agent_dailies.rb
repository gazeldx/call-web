class AddMinutesToReportAgentDailies < ActiveRecord::Migration
  def change
    add_column :report_agent_dailies, :talk_minutes, :integer, default: 0 #通话时长按分钟数计，如：通话3秒算一分钟，通话138秒算三分钟
  end
end