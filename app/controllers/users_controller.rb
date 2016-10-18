class UsersController < BaseController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :menus, :update_menus, :change_password, :update_password]

  def index
    #TODO: Auth.
    @users = current_company.users.includes(:menus, :groups).page(params[:page]).order('created_at DESC')
  end

  def new
    @user = current_company.users.build
  end

  def edit
    authorize(@user, :update?)
  end

  def create
    @user = current_company.users.build(user_params)

    if params[:menus].present?
      begin
        if /^u(\d)+$/.match(user_params[:username].strip)
          flash[:error] =  t('user.invalid_username_format')
          render :new
        else
          @user.create_with_relations!(params[:menus])

          redirect_to users_path, notice: t('user.created')
        end
      rescue
        render :new
      end
    else
      flash[:error] =  t('user.menus_is_required')
      render :new
    end
  end

  def update
    authorize @user

    if @user.update(user_params)
      redirect_to users_path, notice: t('user.updated')
    else
      render :edit
    end
  end

  def menus
    authorize(@user, :update?)
  end

  def update_menus
    authorize(@user, :update?)

    if params[:menus].present?
      @user.update_menus(params[:menus])

      redirect_to users_path, notice: t('user.menus_for_who_success', w: @user.name)
    else
      flash[:error] =  t('user.menus_is_required')
      render :menus
    end
  end

  # 超级管理员修改子管理员的密码, 下同
  def change_password
  end

  def update_password
    @user.update(passwd: Digest::SHA1.hexdigest(params[:user][:passwd]),
                 wrong_password_count: 0)
    flash[:notice] = t(:change_password_success)
    redirect_to change_password_user_path
  end

  # TODO: should fake delete. Just update state.
  def destroy
    authorize(@user, :update?)

    @user.destroy

    redirect_to users_path, notice: t('user.deleted')
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :name, :passwd, group_ids: [], team_ids: [])
  end
end
