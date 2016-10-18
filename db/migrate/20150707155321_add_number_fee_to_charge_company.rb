class AddNumberFeeToChargeCompany < ActiveRecord::Migration
  def change
    add_column :charge_company, :number_fee, :float # 码号月租费
  end
end