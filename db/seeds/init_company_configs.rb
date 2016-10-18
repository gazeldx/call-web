# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:init_company_configs`
j = 0

Company.order(:id).each_with_index do |company, i|
  puts "#{i + 1} company: #{company.id}"

  if company.company_config.blank?
    CompanyConfig.create!(company_id: company.id)

    puts "#{j += 1} Add company_config for company: #{company.id}"
  end
end