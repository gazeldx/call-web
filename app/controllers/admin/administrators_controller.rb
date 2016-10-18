class Admin::AdministratorsController < Admin::BaseController
  before_action :must_admin, except: [:change_self_password, :update_self_password]
  before_action :set_administrator, only: [:show, :edit, :update, :destroy, :points, :update_points, :change_password, :update_password]

  def index
    @administrators = Administrator.includes(:points).page(params[:page]).order('created_at DESC')
  end

  def new
    @administrator = Administrator.new
  end

  def edit
    authorize(@administrator, :update?)
  end

  def create
    @administrator = Administrator.new(administrator_params)

    authorize(@administrator)

    begin
      @administrator.create_with_relations!(params[:points])

      redirect_to admin_administrators_path, notice: t('administrator.created', w: @administrator.name)
    rescue
      render :new
    end
  end

  def update
    authorize(@administrator)

    if @administrator.update(administrator_params)
      redirect_to admin_administrators_path, notice: t('administrator.updated', w: @administrator.name)
    else
      render :edit
    end
  end

  def points
    authorize(@administrator, :update?)
  end

  def update_points
    authorize(@administrator, :update?)

    # if params[:points].present?
      @administrator.update_points(params[:points])

      redirect_to admin_administrators_path, notice: t('administrator.points_for_who_success', w: @administrator.name)
    # else
    #   flash[:error] =  t('administrator.points_is_required')
    #   render :points
    # end
  end

  def change_password
  end

  def update_password
    @administrator.update(passwd: Digest::SHA1.hexdigest(params[:administrator][:passwd]),
                          wrong_password_count: 0)
    flash[:notice] = t(:change_someone_password_success, w: @administrator.name)
    redirect_to admin_administrators_path
  end

  def change_self_password
    @administrator = current_user
  end

  def update_self_password
    @administrator = Administrator.find(session[:id])

    if Digest::SHA1.hexdigest(params[:administrator][:original_password]) != @administrator.passwd
      flash[:error] = t(:original_password_wrong)
    else
      @administrator.update_attribute(:passwd, Digest::SHA1.hexdigest(params[:administrator][:passwd]))

      flash[:notice] = t(:change_password_success)
    end

    redirect_to admin_change_password_path
  end

  # TODO: should fake delete. Just update state.
  def destroy
    authorize(@administrator, :update?)

    @administrator.destroy

    redirect_to admin_administrators_path, notice: t('administrator.deleted')
  end

  private

  def must_admin
    redirect_to admin_root_path unless current_user.admin?
  end

  def set_administrator
    @administrator = Administrator.find(params[:id])
  end

  def administrator_params
    params.require(:administrator).permit(:username, :name, :passwd, :kind, :extension, :phone, :qq, :weixin, :email)
  end
end
