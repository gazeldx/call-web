# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:init_bundle_number`
Bundle.where('number_id > 0').each_with_index do |bundle, i|
  bundle.number = Number.find(bundle.number_id).try(:number)
  bundle.save!

  puts "bundle #{i} processed"
end