class SalesmenController < BaseController
  include Search

  before_action :set_salesman, only: [:edit, :update, :change_password, :update_password]

  def index
    @salesmen = current_company.salesmen
    @salesmen = equal_search(@salesmen, [:team_id, :active])
    @salesmen = like_search(@salesmen, [:name, :username])
    @salesmen = @salesmen.includes(:agent).page(params[:page]).order('created_at DESC')
  end

  def new
    @salesman = Salesman.new
  end

  def create
    @salesman = current_company.salesmen.build(salesman_params)
    authorize @salesman
    agent_taken = false # 座席是否已经被绑定到其他销售员
    if params[:agent_id].present?
      agent_taken = true unless Agent.find(params[:agent_id]).salesman_id.nil?
    end
    if agent_taken
      flash[:error] = t('salesman.agent_taken')
      render :new
    else
      if @salesman.save
        create_show_numbers
        if params[:agent_id].present?
          agent = Agent.find(params[:agent_id])
          agent.update_attributes(salesman_id: @salesman.id)
          RedisHelp.set_agent_salesman_id(agent.id, @salesman.id)
        end
        redirect_to '/salesmen?active=true', notice: t('salesman.created')
      else
        render :new
      end
    end
  end

  def edit
    authorize(@salesman, :update?)

    set_return_to
  end

  def update
    authorize @salesman
    agent_changed = true
    agent_changed = false if @salesman.agent.try(:id).to_s == params[:agent_id]
    agent_taken = false # 座席是否已经被绑定到其他销售员
    if agent_changed
      # 验证该agent_id是否可用，因为一个座席只能绑定到一个销售员上
      if params[:agent_id].present?
        agent_taken = true unless Agent.find(params[:agent_id]).salesman_id.nil?
      end
    end
    if agent_taken
      flash[:error] = t('salesman.agent_taken')
      render :edit
    else
      if @salesman.update(salesman_params) # 注意，这里的salesman_params里面是没有params[:agent_id]的, 所以update后, @salesman.agent是原来绑定的座席
        update_show_numbers

        if agent_changed
          @salesman.agent.update_salesman_id(nil) if @salesman.agent.present? # @salesman.agent是原来绑定的座席
          Agent.find(params[:agent_id]).update_salesman_id(@salesman.id) if params[:agent_id].present?
        end

        flash[:notice] = t('salesman.updated')
        return_to
      else
        render :edit
      end
    end
  end

  def change_password
  end

  def update_password
    @salesman.update(passwd: Digest::SHA1.hexdigest(params[:salesman][:passwd]),
                     wrong_password_count: 0)
    flash[:notice] = t(:change_password_success)
    redirect_to change_password_salesman_path
  end

  private

  def set_salesman
    @salesman = Salesman.find(params[:id])
  end

  def salesman_params
    params.require(:salesman).permit(:username, :name, :passwd, :team_id, :active)
  end

  def update_show_numbers
    @salesman.sales_numbers.delete_all
    create_show_numbers
  end

  def create_show_numbers
    params[:numbers].to_a.each { |number| @salesman.sales_numbers.create(show_number: number) }
  end
end
