Administrator.create!(username: Administrator::USERNAME_ADMIN, name: 'Administrator', passwd: 'Tongyi123CP')

menus = %w[account_info notice.management fee.record
           bundle.automatic bundle.predict bundle.keypress_transfer bundle.timeout_transfer bundle.keypress_gather
           group.management agent.management cdr.list cdr.export cdr.view_fee record.list record.download
           salesman.management monitor.agents monitor.tasks monitor.queues
           report.management report.agent report.operation report.contact_result
           ivr.history queue.history agent.history
           customer.column_define customer.management sales_clue todo.management
           ivr.upload ivr.settings ivr.strategy
           form.settings logo.customize knowledge_library
           ivr.inbound_config ivr.extension_config ivr.exchange ivr.color_ring ivr.vip
           report.satisfaction_statistics]
menus.each do |menu_name|
  Menu.create!(name: menu_name)
end

points = %w[company.management phone_number.management number.management voice.management charge_change.management disabled_agent.management charge_company.recharge server_ip.management]
points.each do |point_name|
  Point.create!(name: point_name)
end

#IVR 节点 id从10000开始自增
ActiveRecord::Base.connection.execute("select setval('nodes_id_seq',10000,false)")

fee_types = %w[座席功能费 号码月租 套餐费 套餐外语音通信费 套餐外短信费 套餐保底冻结 企业保底]
fee_types.each_with_index do |menu_name, i|
  FeeType.create!(id: i + 1, name: menu_name)
end

# TODO: 可能需要加入计费套餐的所有相关数据（特别是3002这个套餐，即“手拨150包月”，目前是3002，程序里用到这个值，在ChargeAgentMonthly类中）