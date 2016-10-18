module MenusHelper
  def all_menus
    {
      'bundle.management' => { icon: 'dashboard', 'bundle.automatic' => "#{automatic_calls_path}", 'bundle.predict' => predict_calls_path },
      'menus.call' => { icon: 'play-circle', 'cdr.list' => cdrs_path, 'invalid_cdr.list' => invalid_cdrs_path, 'record.list' => download_records_packages_path },
      'menus.monitor' => { icon: 'user', 'monitor.agents' => agents_monitor_path, 'monitor.tasks' => "under_construction_#{index}", 'monitor.queues' => "under_construction_#{index}" },
      'menus.report' => { icon: 'list', 'report.management' => "under_construction_#{index}", 'report.agent' => "#{report_agent_today_path}", 'report.operation' => "under_construction_#{index}", 'report.contact_result' => "under_construction_#{index}", 'report.satisfaction_statistics' => satisfaction_statistics_path },
      'menus.customer' => { icon: 'camera', 'sales_clue' => "#{customers_path}?act=#{Customer::ACT_CLUE}", 'customer.management' => customers_path, 'todo.management' => "under_construction_#{index}", 'customer.column_define' => columns_path },
      'menus.account' => { icon: 'desktop', 'issue.management' => issues_path, 'account_info' => users_path, 'notice.management' => "under_construction_#{index}", 'fee.record' => bills_path },
      'menus.agent' =>  {icon: 'male', 'group.management' => groups_path, 'agent.management' => agents_path, 'team.management' => teams_path, 'salesman.management' => '/salesmen?active=true' },
      'ivr.management' => { icon: 'headphones', 'ivr.upload' => "under_construction_#{index}", 'ivr.inbound_config' => inbound_configs_path, 'ivr.extension_config' => extension_configs_path, 'ivr.exchange' => exchange_path, 'ivr.color_ring' => color_ring_path, 'ivr.settings' => ivrs_path, 'ivr.strategy' => strategies_path, 'ivr.vip' => vips_path, 'ivr.satisfaction' => satisfaction_index_path },
      'form.management' => { icon: 'text-width', 'form.settings' => "under_construction_#{index}" },
      'menus.system' => { icon: 'print', 'logo.customize' => logo_name_path, 'knowledge_library' => "under_construction_#{index}"},
      'menus.traffic' => { icon: 'book', 'ivr.history' => "under_construction_#{index}", 'queue.history' => "under_construction_#{index}", 'agent.history' => "under_construction_#{index}" },
    }
  end

  def inner_menus
    {
      'cdr.list' => ['cdr.export', 'record.download', 'cdr.view_fee'],
      'sales_clue' => ['customer.export']
    }
  end

  def query_path_by_menu_name(menu_name)
    all_menus.each do |_, second_menus|
      if second_menus[menu_name].present?
        return second_menus[menu_name]
      end
    end
  end

  def active_menu_link(path)
    "#{'active' if parse_controller_path(request.path_info) == path.sub(/\?.+/, '')}" #path.sub(/\?.+/, '')的用意是去掉?后面的内容, 如: "/salesmen?active=true"将被替换为"/salesmen"
  end

  def active_admin_link(path)
    "#{'active' if request.path_info.include?(path)}"
  end

  def under_construction_menu_link_css(path)
    ' light-grey ' if path.include?('under_construction')
  end

  def active_menu_link_for_customers(path)
    "#{'active' if parse_controller_path(request.path_info) == path}"
  end

  private

  def index
    @under_construction_index = @under_construction_index.to_i + 1
  end
end
