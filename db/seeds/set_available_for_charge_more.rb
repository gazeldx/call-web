# 批量更新的善后工作: 二次补款
#   2016年3月1日, 因为处理月底禁用的icc_scheduler程序连接数据库失败, 而导致的故障
# You can run this seed by `$ rake db:seed:set_available_for_charge_more`
companies = [
    [60068, -2377.637],
    [60091, -2698.634],
    [60137, -435.734],
    [60164, -338.756],
    [60178, -364.57],
    [60292, -99.0],
    [60296, -441.69],
    [60304, -114.0],
    [60308, -609.7],
    [60319, -604.68],
    [61009, -2406.294],
    [62007, -2360.561],
    [62040, -990.798],
    [62050, -2718.105],
    [62051, -3899.026],
    [62067, -2717.419],
    [62078, -299.0],
    [64033, -1767.887],
    [64079, -571.471],
    [64093, -1423.165],
    [64104, -1543.96],
    [65050, -963.592],
    [66003, -868.231],
    [66015, -824.249],
    [66025, -650.796],
    [66037, -216.939],
    [66051, -673.067],
    [66077, -194.45],
    [66081, -159.0],
    [67007, -227.688],
    [67036, -999.0],
    [67053, -269.48],
    [67062, -1477.399],
    [67076, -15.426],
    [69043, -753.35]
]

companies.each_with_index do |company_, i|
  puts "==== #{i + 1} #{company_[0]} ===="
  company = Company.find(company_[0])
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

  add_money = sum + company_[1] - 1
  if add_money > 0
    puts "#{i + 1} #{company.id} 前余额:#{company_[1]}元, 需要二次补款:#{add_money}元"

    Recharge.create!(company_id: company.id,
                     operator_id: 1,
                     amount: add_money,
                     balance: company.charge_company.balance + add_money,
                     remark: '程序自动二次补款,补齐余额')

    puts "balance before: #{company.charge_company.balance}"
    company.charge_company.update!(balance: company.charge_company.balance + add_money)
    puts "balance after: #{company.charge_company.balance}"
  end
end

puts 'All over.'