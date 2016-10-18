class AddAppCallIdToCdrs < ActiveRecord::Migration
  def change
    add_column :cdrs, :app_call_id, :string #返回给APP用的唯一ID,APP会用该值查询单条话单
  end
end