# 批量更新的善后工作: 钱够的企业补款
#   2016年3月1日, 因为处理月底禁用的icc_scheduler程序连接数据库失败, 而导致的故障
# You can run this seed by `$ rake db:seed:set_available_for_charge_enough`
puts "==== 钱够的企业补款 ===="
company_ids = DisabledAgent.where(processed: false).pluck(:company_id).uniq.sort
companies = []
Company.where(id: company_ids).order(:id).each_with_index do |company, i|
  if company.charge_company.balance > 0
    companies << company
  end
end

result_array = []
companies.each_with_index do |company, i|
  sum = 0
  DisabledAgent.where(company_id: company.id).each do |disabled_agent|
    charge_agent = disabled_agent.agent.charge_agent
    if charge_agent.monthly_rent > 0
      puts "#{charge_agent.agent_id}有功能费"
    end

    fee = 0
    if charge_agent.charge_id.to_s[0] == '3'
      fee = ChargeAgentMonthly.find(charge_agent.charge_id).fee
    elsif charge_agent.charge_id.to_s[0] == '2'
      fee = ChargeAgentExceedFree.find(charge_agent.charge_id).min_fee
    elsif charge_agent.charge_id.to_s[0] == '1'
      fee = ChargeAgentMinutely.find(charge_agent.charge_id).fee
    end
    sum += fee
  end

  add_money = sum
  if add_money > 0
    puts "#{i + 1} #{company.id} 前余额:#{company.charge_company.balance}元, 需补款:#{add_money}元"

    Recharge.create!(company_id: company.id,
                     operator_id: 1,
                     amount: add_money,
                     balance: company.charge_company.balance + add_money,
                     remark: '程序自动补款，补齐余额。')

    puts "补款前余额: #{company.charge_company.balance}"
    company.charge_company.update!(balance: company.charge_company.balance + add_money)
    puts "补款后余额: #{company.charge_company.balance}"

    result_array << [company.id, add_money]
  end
end

puts result_array

puts result_array.inspect


puts '==== 钱够的企业补款完成 ==== '