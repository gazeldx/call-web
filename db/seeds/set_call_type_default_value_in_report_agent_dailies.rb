# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:set_call_type_default_value_in_report_agent_dailies`
updated_count = ReportAgentDaily.update_all(call_type: ReportAgentDaily::CALL_TYPE_OUTBOUND)
puts "共#{updated_count}个空值的call_type被更新为#{ReportAgentDaily::CALL_TYPE_OUTBOUND}"