class Admin::ChargeCompany400Controller < Admin::BaseController
  before_action :set_charge, only: [:edit, :update, :destroy]

  def index
    @charges = ChargeCompany400.order(:id)
  end

  def new
    @charge_company400 = ChargeCompany400.new
  end

  def edit
  end

  def create
    @charge_company400 = ChargeCompany400.new(charge_params)

    if @charge_company400.save
      redirect_to admin_charge_company400_index_path, notice: t(:created)
    else
      render :new
    end
  end

  def update
    if @charge_company400.update(charge_params)
      redirect_to admin_charge_company400_index_path, notice: t(:updated)
    else
      render :edit
    end
  end

  private

  def set_charge
    @charge_company400 = ChargeCompany400.find(params[:id])
  end

  def charge_params
    params.require(:charge_company400).permit(:id, :name, :price)
  end
end
