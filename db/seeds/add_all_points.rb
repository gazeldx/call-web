# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:add_all_points`
points = %w[company.management phone_number.management number.management voice.management charge_change.management disabled_agent.management charge_company.recharge]

points.each do |point_name|
  Point.create!(name: point_name)
end

puts "All points added!"