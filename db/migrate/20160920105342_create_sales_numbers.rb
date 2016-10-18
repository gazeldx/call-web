# 表名：销售员对应的主叫号码表(用于销售员自行在页面上修改自己的主叫号码)
class CreateSalesNumbers < ActiveRecord::Migration
  def change
    create_table :sales_numbers do |t|
      t.belongs_to :salesman, index: true
      t.string     :show_number, index: true
    end
  end
end
