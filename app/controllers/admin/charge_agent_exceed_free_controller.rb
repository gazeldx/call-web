class Admin::ChargeAgentExceedFreeController < Admin::BaseController
  before_action :set_charge, only: [:edit, :update, :destroy]

  def index
    @charges = ChargeAgentExceedFree.order(:id)
  end

  def new
    @charge_agent_exceed_free = ChargeAgentExceedFree.new
  end

  def edit
  end

  def create
    @charge_agent_exceed_free = ChargeAgentExceedFree.new(charge_params)

    if @charge_agent_exceed_free.save
      redirect_to admin_charge_agent_exceed_free_index_path, notice: t(:created)
    else
      render :new
    end
  end

  def update
    if @charge_agent_exceed_free.update(charge_params)
      redirect_to admin_charge_agent_exceed_free_index_path, notice: t(:updated)
    else
      render :edit
    end
  end

  private

  def set_charge
    @charge_agent_exceed_free = ChargeAgentExceedFree.find(params[:id])
  end

  def charge_params
    params.require(:charge_agent_exceed_free).permit(:id, :name, :max_fee, :min_fee, :price, :kind)
  end
end
