# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:add_menu_download_record`
menu = Menu.create!(name: 'record.download')

puts "Menu 'record.download' added!"

Company.all.each_with_index do |company, i|
  CompaniesMenus.create!(menu_id: menu.id, company_id: company.id)

  puts "#{i} company: #{company.id}'s CompaniesMenus of 'record.download' created!"
end

User.all.each_with_index do |user, i|
  if user.have_menu?('cdr.list') && !user.admin?
    MenusUsers.create!(menu_id: menu.id, user_id: user.id)
  end

  puts "#{i} user: #{user.id}'s MenusUsers of 'record.download' created!"
end