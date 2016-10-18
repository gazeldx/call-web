# 模块：基础模块
# 表名：企业合法IP地址
class CreateValidIps < ActiveRecord::Migration
  def change
    create_table :valid_ips do |t|
      t.belongs_to  :company, index: true
      t.string      :ip
      t.string      :remark
      t.timestamps
    end
  end
end


