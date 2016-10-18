# 模块：CRM
# 表名：自定义数据列
# 描述：定义出的数据是给 customers 和 销售线索 使用的
class CreateColumns < ActiveRecord::Migration
  def change
    create_table :columns do |t|
      t.belongs_to :company, index: true
      t.string     :name # 值是s3, t1, d2, dt2这样的数据。's'起头表示输入型， 't'起头表示下拉选框型(下拉选项值需要关联options表)， 'd'起头表示日期型，'dt'起头表示时间型；N表示第几个
      t.string     :title
      t.integer    :width
      t.boolean    :active #{true: 显示, false: 隐藏}
      t.timestamps
    end

    # add_column :columns, :target, :integer # 使用者: { 0: 二者都用, 1: 只给customers使用, 2: 只给销售线索使用 }
  end
end
