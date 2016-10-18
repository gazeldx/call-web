# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:update_nil_import_customers_count_in_company_configs`
updated_count = CompanyConfig.update_all(import_customers_count: CompanyConfig::IMPORT_CUSTOMERS_COUNT_LEVEL_1)
puts "共#{updated_count}个空值的import_customers_count被更新为30000"