# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:init_fee_types`
fee_types = %w[座席月租 号码月租 套餐费 套餐外语音通信费 套餐外短信费]

fee_types.each_with_index do |menu_name, i|
  FeeType.create!(id: i + 1, name: menu_name)
end