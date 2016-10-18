class AddStateToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :state, :integer, default: 1 # {1: 正常, 2: 申请下线, 3: 申请下线审核通过}
    remove_column :companies, :active, :boolean, default: true # 用state后, acitve字段不再使用
  end
end