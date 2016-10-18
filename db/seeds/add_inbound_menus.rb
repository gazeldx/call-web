# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:add_inbound_menus`
menus = %w[ivr.inbound_config ivr.extension_config ivr.exchange]
menus.each do |menu_name|
  Menu.create!(name: menu_name)
end