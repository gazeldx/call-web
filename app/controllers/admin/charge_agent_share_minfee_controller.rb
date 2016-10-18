class Admin::ChargeAgentShareMinfeeController < Admin::BaseController
  before_action :set_charge, only: [:edit, :update, :destroy]

  def index
    @charges = ChargeAgentShareMinfee.order(:id)
  end

  def new
    @charge_agent_share_minfee = ChargeAgentShareMinfee.new
  end

  def edit
  end

  def create
    @charge_agent_share_minfee = ChargeAgentShareMinfee.new(charge_params)

    if @charge_agent_share_minfee.save
      redirect_to admin_charge_agent_share_minfee_index_path, notice: t(:created)
    else
      render :new
    end
  end

  def update
    if @charge_agent_share_minfee.update(charge_params)
      redirect_to admin_charge_agent_share_minfee_index_path, notice: t(:updated)
    else
      render :edit
    end
  end

  # def destroy
  #   @charge_agent_share_minfee.destroy
  #
  #   redirect_to admin_charge_agent_share_minfee_path, notice: t('charge.deleted')
  # end

  private

  def set_charge
    @charge_agent_share_minfee = ChargeAgentShareMinfee.find(params[:id])
  end

  def charge_params
    params.require(:charge_agent_share_minfee).permit(:id, :name, :min_fee, :price, :kind)
  end
end
