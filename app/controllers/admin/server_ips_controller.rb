class Admin::ServerIpsController < Admin::BaseController
  before_action :set_server_ip, only: [:edit, :update, :destroy]

  def index
    @server_ips = ServerIp.order(:id)
  end

  def new
    @server_ip = ServerIp.new
  end

  def edit
  end

  def create
    @server_ip = ServerIp.new(server_ip_params.merge(login_passwd: (server_ip_params[:server_type] == ServerIp::SERVER_TYPE_FREESWITCH.to_s ? ServerIp::LOGIN_PASSWD_DEFAULT : nil)))

    if @server_ip.save
      redirect_to admin_server_ips_path, notice: t('server_ip.created')
    else
      render :new
    end
  end

  def update
    if @server_ip.update(server_ip_params)
      redirect_to admin_server_ips_path, notice: t('server_ip.updated')
    else
      render :edit
    end
  end

  # def destroy
  #   @server_ip.destroy
  #
  #   redirect_to admin_server_ips_path, notice: t('server_ip.deleted')
  # end

  private

  def set_server_ip
    @server_ip = ServerIp.find(params[:id])
  end

  def server_ip_params
    params.require(:server_ip).permit(:external_ip, :internal_ip, :name, :port, :server_type)
  end
end
