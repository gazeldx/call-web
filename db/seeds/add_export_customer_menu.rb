# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:add_export_customer_menu`
Menu.create!(name: 'customer.export')
puts "Menu 'customer.export' added!"

menu_id = Menu.find_by_name('customer.export').id
Company.find(CompanyConfig.where(export_customers: true).pluck(:company_id)).each do |company|
  begin
    CompaniesMenus.create!(company_id: company.id, menu_id: menu_id)
    puts "CompaniesMenus #{{company_id: company.id, menu_id: menu_id}} created!"
  rescue Exception => e
    puts "#{i} 有异常： #{e.message}"
  end
end