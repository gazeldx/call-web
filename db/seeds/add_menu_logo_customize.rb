# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:add_menu_logo_customize`
menu = Menu.find_by_name('logo.customize')

deleted_count = CompaniesMenus.where(menu_id: menu.id).delete_all
puts "CompaniesMenus 中 'logo.customize' 老数据共#{deleted_count}条被清除掉!"

Company.order(:id).each_with_index do |company, i|
  CompaniesMenus.create!(menu_id: menu.id, company_id: company.id)

  puts "#{i} company: #{company.id}'s CompaniesMenus of 'logo.customize' created!"
end