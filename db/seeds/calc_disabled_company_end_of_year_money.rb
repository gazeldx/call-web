# 本文件用于年底企业停用包月座席的计费统计，本程序用于在备份服务器上统计禁用的企业的应该补的金额
# company_ids参数是由`rake db:seed:calc_disabled_company_end_of_year date=20150104`返回的
# You can run this seed like this `$ rake db:seed:calc_disabled_company_end_of_year_money company_ids=60139,63192`(要在夜里11:20前执行才可以,因为备份数据库每天会自动替换备份)
disabled_company_ids = ENV['company_ids'].split(',').map(&:to_i)
disabled_companies = Company.where(id: disabled_company_ids).order(:id)

puts "统计时间：#{Time.now.strftime('%Y年%-m月%-d日 %H:%M:%S')}"
puts "#{Time.now.strftime('%Y年%-m月%-d日')}共#{disabled_company_ids.size}个企业完全停用，分别是[#{ENV['company_ids']}]"

disabled_companies.each_with_index do |company, i|
  puts "#{company.id} #{ChargeAgent.where(agent_id: Company.find(company.id).agents.where('state <> 0').pluck(:id)).pluck(:charge_id, :agent_id)}" # 本句用于显示企业的所有座席的charge_id

  monthly_agent_count = 0
  money = 0
  agents = company.agents
  agents.each_with_index do |agent, i|
    if ChargeAgentMonthly.pluck(:id).include?(agent.charge_agent.try(:charge_id))
      monthly_agent_count += 1
      money += ChargeAgentMonthly.find(agent.charge_agent.charge_id).fee * DateTime.left_days_this_month_ratio
    end

    if i == agents.size - 1
      puts "#{company.id}（#{company.name}）共#{monthly_agent_count}个包月座席停用，要补款：#{money.round(2)}元"
    end
  end
end