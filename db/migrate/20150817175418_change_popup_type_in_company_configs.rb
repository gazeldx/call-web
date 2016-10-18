class ChangePopupTypeInCompanyConfigs < ActiveRecord::Migration
  def up
    change_column :company_configs, :popup, 'boolean USING CAST(popup AS boolean)', default: false
  end

  def down
    # Do nothing.
  end
end