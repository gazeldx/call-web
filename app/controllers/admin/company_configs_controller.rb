class Admin::CompanyConfigsController < Admin::BaseController
  before_action :set_company, only: [:edit, :create_or_update]

  def edit
    @company_config = (@company.company_config.present? ? @company.company_config : CompanyConfig.new)
    set_return_to
  end

  def create_or_update
    if @company.company_config.present?
      if @company.company_config.update(company_config_params)
        flash[:notice] = t('company_config.updated', w: @company.name_and_id)
        return_to
      else
        @company_config = @company.company_config
        render :edit
      end
    else
      @company_config = @company.build_company_config(company_config_params)

      if @company_config.save
        redirect_to admin_companies_path, notice: t('company_config.created', w: @company.name_and_id)
      else
        render :edit
      end
    end
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_config_params
    params.require(:company_config).permit(:popup, :salesman_can_see_numbers, :import_customers_count, :import_popup_customers_count, :record_kept_months, :obtain_records_limit_ip, :switch_salesman, :logo, :web_name, :login_title_first, :login_title_second)
  end
end
