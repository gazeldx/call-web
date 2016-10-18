# 模块：CRM
# 表名：客户资料表
# 描述：t1, s1等这些列的定义见columns表。
class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.belongs_to  :company, index: true
      t.belongs_to  :salesman
      t.integer     :t1
      t.integer     :t2
      t.integer     :t3
      t.integer     :t4
      t.integer     :t5
      t.integer     :t6
      t.string      :s1 #这是手机号，如果存在效率问题，可以考虑用bigint
      t.string      :s2
      t.string      :s3
      t.string      :s4
      t.string      :s5
      t.date        :d1
      t.date        :d2
      t.date        :d3
      t.datetime    :dt1
      t.datetime    :dt2
      t.integer     :t7
      t.integer     :t8
      t.integer     :t9
      t.string      :s6
      t.string      :s7
      t.string      :s8
      t.string      :s9
      t.string      :s10
      t.string      :s11
      t.string      :s12
      t.string      :s13
      t.string      :s14
      t.string      :s15
      t.string      :s16
      t.string      :s17
      t.string      :s18
      t.string      :s19
      t.string      :s20
      t.timestamps
    end

    add_index :customers, :t1# 这个t1的索引在后面的migration中已经被修改为s1了，t1做索引是当初的笔误。

    # add_index :customers, :s1
    # add_column :customers, :vip_id, :integer # VIP等级id
    # add_column :customers, :act, :integer # 展现方式: { 0: 销售线索和客户资料都展示(这种已经不再使用, 也不存在这种数据), 1: 展示客户资料内容, 2: 展示销售线索内容 }
    # add_column :customers, :state, :integer # 0: 已删除（一个月后会被正式删除） 1: 正常 2: 为弹屏而导入（一个月后会被正式删除）
    # add_index :customers, :salesman_id
    # add_column :customers, :d4, :date
    # add_column :customers, :d5, :date
    # add_column :customers, :call_time, :timestamp # 最近一次呼叫的时间（目前仅在页面点击呼叫时记录）
  end
end
