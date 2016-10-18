# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:calc_duplicated_callee_numbers_in_customers`
# customers = Customer.where(company_id: 67015).select("company_id, s1").group('company_id', 's1').having("count(*) > 1").all.pluck(:company_id, :s1)
customers = Customer.select("company_id, s1").group('company_id', 's1').having("count(*) > 1").all.pluck(:company_id, :s1)

puts "customers 中有 #{customers.count} 个号码存在重复"

# deleted_count = 0
# customers[0..20].each do |customer|
#   company_id = customer[0]
#   s1 = customer[1]
#
#   same_customers = Customer.where(company_id: company_id, s1: s1).order(:id)
#   same_customers.each do |customer|
#     puts "s1: #{customer.s1}, updated_at: #{customer.updated_at.strftime("%-m月%-d日 %H:%M:%S")} #{customer.state == Customer::STATE_OK ? "=== 这个客户状态可用 ===" : ''}"
#   end
#
#   customers_after_reject = same_customers.reject do |same_customer|
#     puts "近期更新: #{same_customer.company_id} #{same_customer.s1}, created_at: #{same_customer.created_at.strftime("%-m月%-d日 %H:%M:%S")}, updated_at: #{same_customer.updated_at.strftime("%-m月%-d日 %H:%M:%S")}" if same_customer.updated_at > Time.now - 7.days
#     if same_customer.updated_at == same_customers.maximum(:updated_at)
#       puts "maximum(:updated_at) s1: #{same_customer.s1}, updated_at: #{same_customer.updated_at.strftime("%-m月%-d日 %H:%M:%S")}"
#     end
#     same_customer.updated_at == same_customers.maximum(:updated_at)
#   end
#   if customers_after_reject.blank?
#     customers_after_reject = [same_customers.last]
#   end
#
#   customers_after_reject.each_with_index do |same_customer, i|
#     deleted_count = deleted_count + 1
#     puts "#{deleted_count} Customer s1 will be updated: s1: #{same_customer.s1}, updated_at: #{same_customer.updated_at.strftime("%-m月%-d日 %H:%M:%S")} #{same_customer.company_id} #{same_customer.contacts.present? ? " contacts: #{same_customer.contacts}" : ''}"
#     # same_customer.destroy
#     # same_customer.update_attribute('s1', "8729522#{i}#{same_customer.s1}")
#   end
# end