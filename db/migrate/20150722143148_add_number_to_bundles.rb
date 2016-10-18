class AddNumberToBundles < ActiveRecord::Migration
  def change
    add_column :bundles, :number, :string # 主叫号码，可以是一个号码或者是用英文逗号分隔的多个号码
  end
end