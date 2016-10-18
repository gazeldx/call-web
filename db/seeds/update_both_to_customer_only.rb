# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:update_both_to_customer_only`
updated_count = Customer.where(act: Customer::ACT_BOTH).update_all(act: Customer::ACT_CUSTOMER)

puts "共#{updated_count}个act=#{Customer::ACT_BOTH}的customers表数据被更新为#{Customer::ACT_CUSTOMER}"