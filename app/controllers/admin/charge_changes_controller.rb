class Admin::ChargeChangesController < Admin::BaseController
  include Search

  before_action :set_charge, only: [:edit, :update, :destroy]

  def index
    @charge_changes = ChargeChange.all
    @charge_changes = equal_search(@charge_changes, [:company_id])
    @charge_changes = @charge_changes.includes(:company).page(params[:page]).order(id: :desc)
  end

  def new
    @charge_change = ChargeChange.new
  end

  def edit
  end

  def create
    @charge_change = ChargeChange.new(charge_params.merge(operator_id: session[:id],
                                                          effective_at: Date.today.at_beginning_of_month.next_month,
                                                          remark: "之前套餐为：#{origin_charge_id}。#{charge_params[:remark]}"))
    authorize @charge_change

    if params[:change_type] == '1' && charge_params[:company_id].present? && charge_params[:min_fee]!= '' && charge_params[:min_fee].to_f < 100
      flash[:error] = '企业的呼出保底不能小于100!'
      render :new
    else
      if @charge_change.save
        redirect_to admin_charge_changes_path, notice: t(:created)
      else
        render :new
      end
    end
  end

  # def update
  #   if @charge_change.update(charge_params)
  #     redirect_to admin_charge_changes_path, notice: t(:updated)
  #   else
  #     render :edit
  #   end
  # end

  def destroy
    @charge_change.destroy

    redirect_to admin_charge_changes_path, notice: t('charge_change.deleted')
  end
  
  private

  def set_charge
    @charge_change = ChargeChange.find(params[:id])
  end

  def charge_params
    params.require(:charge_change).permit(:company_id, :agent_id, :charge_id, :remark, :min_fee)
  end

  def origin_charge_id
    if charge_params[:agent_id].present?
      ChargeAgent.find_by_agent_id(charge_params[:agent_id]).charge_id
    else
      if charge_params[:charge_id].start_with?('6')
        ChargeCompany.find_by_company_id(charge_params[:company_id]).try(:charge_company_outbound_id)
      elsif charge_params[:charge_id].start_with?('4')
        ChargeCompany.find_by_company_id(charge_params[:company_id]).try(:charge_company_400_id)
      end
    end
  end
end
