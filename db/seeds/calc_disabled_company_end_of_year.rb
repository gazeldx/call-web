# 本文件用于年底企业停用包月座席的计费统计，本程序用于在产品服务器上统计哪些企业在昨天被完全禁用
# You can run this seed like this `$ rake db:seed:calc_disabled_company_end_of_year date=20160104`(要在夜里11:20前执行才可以,因为备份数据库每天会自动替换备份)
disabled_companies = []

Company.order(id: :asc).each_with_index do |company, i|
  puts "#{i + 1} #{company.id} #{company.name}"

  latest_updated_at = nil
  agents = company.agents
  agents.each_with_index do |agent, i|
    break unless agent.disabled?

    if latest_updated_at.nil? || agent.updated_at > latest_updated_at
      latest_updated_at = agent.updated_at
    end

    if i == agents.size - 1 && latest_updated_at.strftime('%Y%m%d') == ENV['date']
      disabled_companies << company.id
      puts "#{company.id} #{company.name}, latest_updated_at: #{latest_updated_at.strftime('%Y年%-m月%-d日 %H:%M:%S')}"
    end
  end
end

puts "在#{ENV['date']}停用了所有座席的企业是: #{disabled_companies.join(',')} "
