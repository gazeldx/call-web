# 模块：基础模块
# 表名：服务器IP地址和参数
class CreateServerIps < ActiveRecord::Migration
  def change
    create_table :server_ips do |t|
      t.string      :internal_ip #内网IP
      t.integer     :port
      t.integer     :server_type #1:VOS 2:软交换
      t.string      :name
      t.string      :external_ip #外网IP 目前没有用到
      t.string      :login_user #目前没有用到
      t.string      :login_passwd #目前没有用到
      t.integer     :call_type #目前没有用到。该值可能仅针对线路（对1，2无用）有用。 1:呼出 2:呼入 3:呼入呼出(default)
      t.timestamps
    end
  end
end







