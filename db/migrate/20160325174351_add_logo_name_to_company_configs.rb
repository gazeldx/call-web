class AddLogoNameToCompanyConfigs < ActiveRecord::Migration
  def change
    add_column :company_configs, :logo, :string
    add_column :company_configs, :web_name, :string
    add_column :company_configs, :login_title_first, :string
    add_column :company_configs, :login_title_second, :string
  end
end