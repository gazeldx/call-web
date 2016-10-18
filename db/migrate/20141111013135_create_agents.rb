# 模块：基础模块
# 表名：座席表
# 描述：一个座席对应一个话机，座席可以绑定到销售员，UC按座席计费
class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      # t.integer     :id #前五位企业号，之后四位是座席编号
      t.belongs_to  :salesman
      t.belongs_to  :company, index: true
      t.integer     :state #0:停用 1:启用 2:月底禁用(停用中，数据待清理)
      t.integer     :code #座席编号，四位数字。id的最后四位
      t.string      :extension #（本字段已被删除！）分机号。因为可能对应多个分机号，在分机设置中解决。企业内部转机等用的分机号。
      t.integer     :extension_type #分机类型 1:SIP话机(有线) 2:无线话机
      t.integer     :shown_number_id #（本字段已被删除！）主叫号码，从相关表选择。 因为号码取自号码管理系统了，本字段用string类型的show_number来替代
      t.boolean     :transfer #是否转接到私人号码？ default: false
      t.string      :private_phone #私人号码
      t.boolean     :callback_show_original_number #座席接到呼入电话时，是否显示原始主叫 default: true
      t.integer     :callback_default_number_id #不显示原始主叫的时候，显示的主叫号码。该值从相关表选择#TODO: 目前尚未使用，如果用的话需要改成字符串类型的号码
      t.timestamps
    end

    # add_column :agents, :show_number, :string # 主叫号码
    # remove_column :agents, :extension
    # remove_column :agents, :shown_number_id
  end
end
