# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:add_invalid_cdrs_menu`
menu = Menu.create!(name: 'invalid_cdr.list')

puts "Menu 'invalid_cdr.list' added!"

Company.all.each_with_index do |company, i|
  CompaniesMenus.create!(menu_id: menu.id, company_id: company.id)

  puts "#{i} company_id: #{company.id} CompaniesMenus created!"
end