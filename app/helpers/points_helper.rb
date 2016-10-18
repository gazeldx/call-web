module PointsHelper
  def all_points
    { 'point.general' => { 'company.management' => admin_companies_path, 'phone_number.management' => admin_phone_numbers_path, 'number.management' => admin_numbers_path, 'voice.management' => admin_voices_path, 'charge_change.management' => admin_charge_changes_path, 'disabled_agent.management' => admin_disabled_agents_path },
      'point.special' => { 'charge_company.recharge' => nil, 'server_ip.management' => admin_server_ips_path } }
  end

  def all_points_flatten
    { 'company.management' => { icon: 'dashboard', url: admin_companies_path },
      'phone_number.management' => { icon: 'stackexchange', url: admin_phone_numbers_path },
      'number.management' => { icon: 'text-width', url: admin_numbers_path },
      'voice.management' => { icon: 'music', url: admin_voices_path },
      'charge_change.management' => { icon: 'tags', url: admin_charge_changes_path },
      'disabled_agent.management' => { icon: 'frown', url: admin_disabled_agents_path },
      'server_ip.management' => { icon: 'film', url: admin_server_ips_path } }
  end
end
