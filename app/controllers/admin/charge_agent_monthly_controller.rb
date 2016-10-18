class Admin::ChargeAgentMonthlyController < Admin::BaseController
  before_action :set_charge, only: [:edit, :update, :destroy]

  def index
    @charges = ChargeAgentMonthly.order(:id)
  end

  def new
    @charge_agent_monthly = ChargeAgentMonthly.new
  end

  def edit
  end

  def create
    @charge_agent_monthly = ChargeAgentMonthly.new(charge_params)

    if @charge_agent_monthly.save
      redirect_to admin_charge_agent_monthly_index_path, notice: t(:created)
    else
      render :new
    end
  end

  def update
    if @charge_agent_monthly.update(charge_params)
      redirect_to admin_charge_agent_monthly_index_path, notice: t(:updated)
    else
      render :edit
    end
  end
  
  private

  def set_charge
    @charge_agent_monthly = ChargeAgentMonthly.find(params[:id])
  end

  def charge_params
    params.require(:charge_agent_monthly).permit(:id, :name, :fee, :kind)
  end
end
