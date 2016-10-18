# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:add_cdr_export_menu`
menu = Menu.create!(name: 'cdr.export')

puts "Menu 'cdr.export' added!"

Company.all.each_with_index do |company, i|
  CompaniesMenus.create!(menu_id: menu.id, company_id: company.id)

  puts "#{i} company: #{company.id}'s CompaniesMenus of 'cdr.export' created!"
end