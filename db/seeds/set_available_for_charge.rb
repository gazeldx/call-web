# 批量更新的善后工作
#   2016年3月1日, 因为处理月底禁用的icc_scheduler程序连接数据库失败, 而导致的故障
# You can run this seed by `$ rake db:seed:set_available_for_charge`
company_ids = DisabledAgent.where(processed: false).pluck(:company_id).uniq.sort

companies = []
Company.where(id: company_ids).order(:id).each_with_index do |company, i|
  if company.charge_company.balance < 0
    puts "#{i} #{company.id}"
    companies << company
  end
end

companies.each_with_index do |company, i|
  if company.charge_company.balance < 0
    puts "#{i} #{company.id}"
    company.agents.each do |agent|
      puts "Set available #{agent.id}"
      $redis.set("OUT:#{agent.id}", 'Available')
    end

    Recharge.create!(company_id: company.id,
                     operator_id: 1,
                     amount: 1 - company.charge_company.balance,
                     balance: 1,
                     remark: '程序自动补款,使余额为1元')

    puts "balance: #{company.charge_company.balance}"
    company.charge_company.update!(balance: 1)
    puts "balance new: #{company.charge_company.balance}"
  end
end

puts 'Over'