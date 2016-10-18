module ValidIpsHelper
  def obtain_records?
    !current_company.company_config.obtain_records_limit_ip? || (current_company.valid_ips.pluck(:ip).include?(request.remote_ip))
  end
end
