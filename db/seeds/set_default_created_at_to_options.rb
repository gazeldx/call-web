# 本文件不再使用了，只用于首套系统一次性的数据增补。
# 用途：用于初始化created_at，由于created_at最初没有加入到options表中，所以没有初始值。
# You can run this seed by `$ rake db:seed:set_default_created_at_to_options`
Option.all.each_with_index do |option, i|
  option.created_at = Time.now - 1000 + i
  option.save!
end
