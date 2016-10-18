class Admin::ChargeCompanyController < Admin::BaseController
  before_action :set_company, only: [:edit, :create_or_update]

  def edit
    @charge_company = (@company.charge_company.present? ? @company.charge_company : ChargeCompany.new)
  end

  def create_or_update
    if @company.charge_company.present? # update
      if @company.charge_company.update(charge_company_params)
        redirect_to admin_companies_path, notice: t('charge_company.updated')
      else
        @charge_company = @company.charge_company
        render :edit
      end
    else # create
      @charge_company = @company.build_charge_company(charge_company_params)
      create_return = @charge_company.create_and_deduct_fees(operator_id: session[:id])
      if create_return[:result] == true
        redirect_to task_config_admin_company_path(@company), notice: t('charge_company.created')
      else
        flash[:error] = create_return[:message]
        redirect_to admin_companies_path
      end
    end
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def charge_company_params
    params.require(:charge_company).permit(:balance, :kind, :charge_company_outbound_id, :outbound_min_fee, :charge_company_400_id, :min_fee_400, :charge_company_400_month_id, :effective_date_400, :number_fee, :charge_mode)
  end
end
