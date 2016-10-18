# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:insert_and_update_fee_types`
FeeType.create!(id: 7, name: '企业保底')

FeeType.find(1).update_attribute(:name, '座席功能费')

puts "fee_types表中插入了 7: 企业保底, 更新了 1: 座席功能费"