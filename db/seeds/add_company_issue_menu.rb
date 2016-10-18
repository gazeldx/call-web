# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:add_company_issue_menu`
Company.all.each_with_index do |company, i|
  puts i

  begin
    CompaniesMenus.create!(company_id: company.id,
                           menu_id: Menu.find_by_name('issue.management').id)
  rescue Exception => e
    puts "#{i} 有异常： #{e.message}"
  end
end