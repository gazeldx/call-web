class Admin::ChargeCompanyOutboundController < Admin::BaseController
  before_action :set_charge, only: [:edit, :update, :destroy]

  def index
    @charges = ChargeCompanyOutbound.order(:id)
  end

  def new
    @charge_company_outbound = ChargeCompanyOutbound.new
  end

  def edit
  end

  def create
    @charge_company_outbound = ChargeCompanyOutbound.new(charge_params)

    if @charge_company_outbound.save
      redirect_to admin_charge_company_outbound_index_path, notice: t(:created)
    else
      render :new
    end
  end

  def update
    if @charge_company_outbound.update(charge_params)
      redirect_to admin_charge_company_outbound_index_path, notice: t(:updated)
    else
      render :edit
    end
  end

  private

  def set_charge
    @charge_company_outbound = ChargeCompanyOutbound.find(params[:id])
  end

  def charge_params
    params.require(:charge_company_outbound).permit(:id, :name, :price, :transfer_price)
  end
end
