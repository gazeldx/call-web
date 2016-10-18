class Admin::ChargeAgentMinutelyController < Admin::BaseController
  before_action :set_charge, only: [:edit, :update, :destroy]

  def index
    @charges = ChargeAgentMinutely.order(:id)
  end

  def new
    @charge_agent_minutely = ChargeAgentMinutely.new
  end

  def edit
  end

  def create
    @charge_agent_minutely = ChargeAgentMinutely.new(charge_params)

    if @charge_agent_minutely.save
      redirect_to admin_charge_agent_minutely_index_path, notice: t(:created)
    else
      render :new
    end
  end

  def update
    if @charge_agent_minutely.update(charge_params)
      redirect_to admin_charge_agent_minutely_index_path, notice: t(:updated)
    else
      render :edit
    end
  end

  # def destroy
  #   @charge_agent_minutely.destroy
  #
  #   redirect_to admin_charge_agent_minutely_path, notice: t('charge.deleted')
  # end

  private

  def set_charge
    @charge_agent_minutely = ChargeAgentMinutely.find(params[:id])
  end

  def charge_params
    params.require(:charge_agent_minutely).permit(:id, :name, :fee, :minutes, :price, :kind)
  end
end
