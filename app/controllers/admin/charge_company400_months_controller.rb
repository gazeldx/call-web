class Admin::ChargeCompany400MonthsController < Admin::BaseController
  before_action :set_charge, only: [:edit, :update, :destroy]

  def index
    @charges = ChargeCompany400Month.order(:id)
  end

  def new
    @charge_company400_month = ChargeCompany400Month.new
  end

  def edit
  end

  def create
    @charge_company400_month = ChargeCompany400Month.new(charge_params)

    if @charge_company400_month.save
      redirect_to admin_charge_company400_months_path, notice: t(:created)
    else
      render :new
    end
  end

  def update
    if @charge_company400_month.update(charge_params)
      redirect_to admin_charge_company400_months_path, notice: t(:updated)
    else
      render :edit
    end
  end

  private

  def set_charge
    @charge_company400_month = ChargeCompany400Month.find(params[:id])
  end

  def charge_params
    params.require(:charge_company400_month).permit(:id, :name, :fee, :months, :agent_count)
  end
end
