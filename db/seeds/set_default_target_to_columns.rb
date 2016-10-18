# 本文件不再使用了，只用于首套系统一次性的数据增补。
# 用途：用于初始化columns表的target，由于target最初没有加入到columns表中，所以没有初始值。 之后又加上对customers表中的act字段的处理
# You can run this seed by `$ rake db:seed:set_default_target_to_columns`
Column.all.each do |column|
  column.target = (['s1', 's2', 's3'].include?(column.name) ? Column::TARGET_BOTH : Column::TARGET_CUSTOMER)
  column.save!
end

puts '更新columns表的target已完成！'

Customer.all.each do |customer|
  customer.act = Customer::ACT_CUSTOMER
  customer.s2 = '未填写' if customer.s2.blank?
  customer.save!
end

puts '更新customers表的act已完成！'