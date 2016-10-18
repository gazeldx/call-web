# 模块：CRM
#   Column中类型为“下拉选项”的具体选项
class CreateOptions < ActiveRecord::Migration
  def change
    create_table :options do |t|
      t.belongs_to  :company, index: true
      t.integer     :tid #Column表的t开头的字段id，如't2'，则此处值为2
      t.integer     :value
      t.string      :text
      t.boolean     :active
    end
  end
end
