class ValidIpsController < BaseController
  before_action :set_valid_ip, only: [:edit, :update, :destroy]

  def index
    @valid_ips = current_company.valid_ips.order(:id).page(params[:page])
  end

  def new
    @valid_ip = ValidIp.new
  end

  def edit
  end

  def create
    @valid_ip = current_company.valid_ips.build(valid_ip_params)

    authorize @valid_ip

    if @valid_ip.save
      redirect_to valid_ips_path, notice: t('valid_ip.created')
    else
      render :new
    end
  end

  def update
    authorize current_company.valid_ips.build(valid_ip_params.merge(id: @valid_ip.id))

    if @valid_ip.update(valid_ip_params)
      redirect_to valid_ips_path, notice: t('valid_ip.updated')
    else
      render :edit
    end
  end

  def destroy
    @valid_ip = ValidIp.find(params[:id])
    @valid_ip.destroy
    redirect_to valid_ips_path, notice: t('valid_ip.deleted')
  end

  private

  def set_valid_ip
    @valid_ip = ValidIp.find(params[:id])
  end

  def valid_ip_params
    params.require(:valid_ip).permit(:ip, :remark)
  end
end