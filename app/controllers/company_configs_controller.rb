class CompanyConfigsController < BaseController
  def edit
    @company_config = current_company.company_config
    @company_config.web_name = t('company_config.default_web_name') if @company_config.web_name.blank?
    @company_config.login_title_first = t('company_config.default_login_title_first') if @company_config.login_title_first.blank?
    @company_config.login_title_second = t('company_config.default_login_title_second') if @company_config.login_title_second.blank?
  end

  def update
    @company_config = current_company.company_config
    if @company_config.update(company_config_params)
      set_company_config_session
      redirect_to logo_name_path, notice: t(:updated)
    else
      render :edit
    end
  end

  private

  def company_config_params
    params.require(:company_config).permit(:logo, :web_name, :login_title_first, :login_title_second)
  end
end
