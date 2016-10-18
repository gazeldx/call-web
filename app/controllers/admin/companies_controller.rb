class Admin::CompaniesController < Admin::BaseController
  include Search

  before_action :has_point_company_management?
  before_action :set_company, only: [:edit, :update, :destroy, :menus, :update_menus, :batch_new_agents, :batch_create_agents, :batch_charge_agents, :do_batch_charge_agents, :batch_charge_change, :do_batch_charge_change, :batch_disable_eom, :do_batch_disable_eom, :vos_config, :update_vos_config, :assign_administrators, :do_assign_administrators, :recharge, :update_balance, :login_as_company_admin, :apply_for_vacuum, :verify_for_vacuum_application, :refuse_for_vacuum_application, :start_vacuum]
  before_action :set_return_to, only: [:edit, :menus, :vos_config, :apply_for_vacuum, :verify_for_vacuum_application, :refuse_for_vacuum_application, :start_vacuum]

  def index
    @companies = Company.all

    @companies = equal_search(@companies, [:id, :state])

    @companies = like_search(@companies, [:name])

    # TODO: 这里的includes([salesmen: :agent])可能需要优化。
    @companies = @companies.includes([salesmen: :agent], :phone_numbers, :charge_company).page(params[:page]).order('created_at DESC')
  end

  def new
    @company = Company.new
  end

  def edit
  end

  def create
    @company = Company.new(company_params)

    if params[:menus].present?
      begin
        @company.create_with_relations!(params[:menus])

        flash[:notice] = "#{t('company.created')}</br>" \
                         "还为该企业配备了一个“#{t(:user_)}”用户，用户名“#{@company.admin.username}”。"

        create_nbms_company

        redirect_to charge_company_admin_company_path(@company)
      rescue Exception => exception
        flash[:error] =  exception.to_s
        render :new
      end
    else
      flash[:error] =  t('company.menus_is_required')
      render :new
    end
  end

  def update
    is_new_company = @company.name.include?(t('company.name_ready')) && !company_params[:name].include?(t('company.name_ready'))
    if is_new_company
      @company.name = company_params[:name] # 这个是用于传入create_nbms_company中的新企业名称。
      create_nbms_company
    end

    if flash[:error].present?
      render :edit
      return
    end

    if @company.update(company_params.merge(is_new_company ? { created_at: Time.now } : {}))
      flash[:notice] = "#{t('company.updated', w: @company.name_and_id)} #{flash[:notice]}"
      return_to
    else
      render :edit
    end
  end

  def assign_administrators
  end

  def do_assign_administrators
    @company.update(company_params)

    redirect_to admin_companies_path, notice: t('company.assign_company_administrators_success', w: @company.name)
  end

  def vos_config
  end

  def update_vos_config
    @company.update_vos_config(company_params)

    flash[:notice] = t('success', w: t('company.vos_config'))
    return_to
  end

  def batch_config_vos
  end

  def do_batch_config_vos
    Company.where("id >= #{params[:company_id_begin]} and id <= #{params[:company_id_end]}").order(:id).each_with_index do |company, i|
      old_trunk = $redis.hgetall("acdqueue:trunk:#{company.id}")

      if company.try("#{params[:vos_type]}_vos_id".to_sym) == params[:current_vos_id].to_i && old_trunk.present?
        # logger.warn "#{i} #{company.id} +++++++++++++++++ before data in PostgreSQL: { manual_call_vos_id: #{company.manual_call_vos_id}, task_vos_id: #{company.task_vos_id}, callback_vos_id: #{company.callback_vos_id} }, redis: {#{"manualcall_trunk_ip: #{old_trunk['manualcall_trunk_ip']}, task_trunk_ip: #{old_trunk['task_trunk_ip']}, callback_trunk_ip: #{old_trunk['callback_trunk_ip']}" if old_trunk.present?}} #{old_trunk.inspect}"
        company.update!("#{params[:vos_type]}_vos_id" => params[:new_vos_id])
        $redis.mapped_hmset("acdqueue:trunk:#{company.id}", { "#{params[:vos_type]}".sub('_', '') + "_trunk_ip" => ServerIp.find(params[:new_vos_id]).internal_ip })
        # new_trunk = $redis.hgetall("acdqueue:trunk:#{company.id}")
        # logger.warn "#{i} #{company.id} +++++++++++++++++  after data in PostgreSQL: { manual_call_vos_id: #{company.manual_call_vos_id}, task_vos_id: #{company.task_vos_id}, callback_vos_id: #{company.callback_vos_id} }, redis: {#{"manualcall_trunk_ip: #{new_trunk['manualcall_trunk_ip']}, task_trunk_ip: #{new_trunk['task_trunk_ip']}, callback_trunk_ip: #{new_trunk['callback_trunk_ip']}" if new_trunk.present?}} #{new_trunk.inspect}"
      end
    end

    flash[:notice] = '已完成批量设置！'
    redirect_to admin_batch_config_vos_path
  end

  def menus
  end

  def update_menus
    if params[:menus].present?
      @company.update_menus(params[:menus])

      flash[:notice] = t('company.update_menus_success', w: @company.name)
      return_to
    else
      flash[:error] =  t('company.menus_is_required')
      render :menus
    end
  end

  def apply_for_vacuum
    flash[:notice] = "“#{@company.name_and_id}”下线并清理数据申请已提交。" if @company.update(state: Company::STATE_APPLY_FOR_VACUUM)
    return_to
  end

  def verify_for_vacuum_application
    flash[:notice] = "您已批准“#{@company.name_and_id}”的下线申请。" if @company.update(state: Company::STATE_APPLY_FOR_VACUUM_VERIFIED)
    return_to
  end

  def refuse_for_vacuum_application
    flash[:notice] = "您已驳回“#{@company.name_and_id}”的下线申请。该企业正常使用。" if @company.update(state: Company::STATE_OK)
    return_to
  end

  def start_vacuum
    authorize @company

    vacuum_nbms_data
    if flash[:error].present?
      return_to
      return
    end

    flash[:error] = "#{flash[:error]}<br>原企业“#{@company.id}”上传的语音和Logo图片清理失败，请联系研发报障！" unless @company.vacuum_uploaded_files
    if flash[:error].present?
      return_to
      return
    end

    @company.vacuum
    flash[:notice] = "#{flash[:notice]}<br>原企业数据已经清空，企业编号“#{@company.id}”可用于新企业开户。"
    return_to
  end

  def batch_new_agents
  end

  def batch_create_agents
    if balance_not_enough?
      flash[:error] = t('company.balance_not_enough', w: fee_for_batch_create_agents.round(2))

      redirect_to admin_company_agents_path(@company)
    elsif agent_id_taken?(params[:agent_code_start].to_i, params[:agent_count].to_i)
      flash[:error] = t('agent.id_taken')

      redirect_to admin_company_agents_path(@company)
    else
      @company.batch_create_agents!(params[:agent_code_start].to_i,
                                    params[:agent_count].to_i,
                                    params[:show_number],
                                    { charge_id: params[:charge_id], monthly_rent: params[:monthly_rent], fee_for_batch_create_agents: fee_for_batch_create_agents })

      flash[:notice] = t('agent.batch_created')

      redirect_to admin_company_agents_path(@company)
    end
  end

  def batch_charge_agents
  end

  def do_batch_charge_agents
    finished_agent_ids = []
    wanted_agent_ids = ChargeAgent.where(agent_id: @company.agents.ok.order(:id).pluck(:id), charge_id: nil).pluck(:agent_id) & params['agent_ids'].map { |agent_id| agent_id.to_i }
    wanted_agent_ids.each do |agent_id|
      @charge_agent = ChargeAgent.find_by_agent_id(agent_id)
      if single_charge_balance_not_enough?
        remain_agent_ids = wanted_agent_ids - finished_agent_ids
        flash[:error] = "之后，企业余额不足，还有#{remain_agent_ids.size}个座席（#{remain_agent_ids.map { |agent_id| agent_id.to_s.sub("#{@company.id}", '').to_i }}）未处理。#{t('company.balance_not_enough', w: fee_for_charge_agent * remain_agent_ids.size)}"
        break
      else
        @charge_agent.create_charge!({ charge_id: params[:charge_id], monthly_rent: params[:monthly_rent] })
        finished_agent_ids << agent_id
      end
    end
    flash[:notice] = "#{finished_agent_ids.size}个座席完成了计费设置，它们是#{finished_agent_ids.map { |agent_id| agent_id.to_s.sub("#{@company.id}", '').to_i }}。"
    redirect_to admin_company_agents_path(@company)
  end

  def batch_charge_change
  end

  def do_batch_charge_change
    success_agent_ids = []
    params_agent_ids = params['agent_ids'].map { |agent_id| agent_id.to_i }
    (@company.can_charge_change_agent_ids & params_agent_ids).each do |agent_id|
      charge_change = ChargeChange.new(agent_id: agent_id,
                                       charge_id: params['charge_id'],
                                       company_id: @company.id,
                                       operator_id: session[:id],
                                       effective_at: Date.today.at_beginning_of_month.next_month,
                                       remark: "之前套餐为：#{ChargeAgent.find_by_agent_id(agent_id).charge_id}。#{params[:remark]}")
      if policy(charge_change).agent_charge_changed?
        charge_change.save!
        success_agent_ids << agent_id
      end
    end
    flash[:notice] = "#{success_agent_ids.size}个座席下月套餐已变更，它们是#{success_agent_ids.map { |agent_id| agent_id.to_s.sub("#{@company.id}", '').to_i }}。"
    if (params_agent_ids - success_agent_ids).present?
      flash[:error] = "#{(params_agent_ids - success_agent_ids).map { |agent_id| agent_id.to_s.sub("#{@company.id}", '').to_i }}下月套餐未变更，原因是你没有对该座席的套餐做任何修改或该座席在本月已经做过套餐变更。"
    end
    redirect_to admin_company_agents_path(@company)
  end

  def batch_disable_eom
  end

  def do_batch_disable_eom
    success_agent_ids = []
    params_agent_ids = params['agent_ids'].map { |agent_id| agent_id.to_i }
    (@company.agents.ok.order(:id).pluck(:id) & params_agent_ids).each do |agent_id|
      if policy(Agent.find(agent_id)).disable_eom?
        DisabledAgent.create!(company_id: @company.id, agent_id: agent_id)
        success_agent_ids << agent_id
      end
    end
    flash[:notice] = "#{success_agent_ids.size}个座席月底将被禁用，它们是#{success_agent_ids.map { |agent_id| agent_id.to_s.sub("#{@company.id}", '').to_i }}。"
    if (params_agent_ids - success_agent_ids).present?
      flash[:error] = "#{(params_agent_ids - success_agent_ids).map { |agent_id| agent_id.to_s.sub("#{@company.id}", '').to_i }}的月底禁用本来就已经创建了，不需要重复操作。"
    end
    redirect_to admin_company_agents_path(@company)
  end

  def recharge
  end

  def update_balance
    recharge = @company.recharges.build(amount: params[:amount].to_f, operator_id: session[:id], remark: params[:remark])

    authorize(recharge, :create?)

    @company.update_balance(recharge)

    redirect_to admin_companies_path, notice: t('company.recharge_success', w: "#{@company.id} - #{@company.name}")
  end

  # 用于和“号码管理系统”对接，创建一个企业。该接口调用是在创建企业的时候自动发起的，不过有些老企业或者特殊情况，需要通过本方法进行人工插入。
  # 示例：http://localhost:9292/admin/create_old_company_nbms_data?company_id=60001
  def create_old_company_nbms_data
    @company = Company.find(params[:company_id])

    create_nbms_company if @company.present?
  end

  def login_as_company_admin
    administrator_id = session[:id]

    clear_session

    @_person = User.find_by_username(@company.admin.username)

    set_login_session
    session[:administrator_id] = administrator_id # 是UC管理员以企业超级管理员身份登陆企业后台时，做的一个标识，值为Administrator表的id值。

    flash[:notice] = t('success', w: t(:login))
    redirect_to root_path
  end

  def login_as_company_salesman
    administrator_id = session[:id]

    clear_session

    @_person = @salesman = Salesman.find(params[:salesman_id])

    set_login_session
    session[:administrator_id] = administrator_id # 是UC管理员以企业超级管理员身份登陆企业后台时，做的一个标识，值为Administrator表的id值。

    flash[:notice] = t('success', w: t(:login))
    redirect_to root_path
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:id, :name, :license, :mobile, :manual_call_vos_id, :callback_vos_id, :task_vos_id, :manual_call_prefix, :callback_prefix, :task_prefix, :helper_id, :technician_id, :seller_id)
  end

  def has_point_company_management?
    redirect_to admin_root_path unless current_user.have_point('company.management')
  end

  def fee_for_batch_create_agents
    fee = 0
    fee = ChargeAgent.charge_fee(params[:charge_id], @company.id) if params[:charge_id].to_i > 0
    params[:agent_count].to_i * (fee + monthly_rent_this_month)
  end

  def fee_for_charge_agent
    fee = 0
    fee = ChargeAgent.charge_fee(params[:charge_id], @company.id) if params[:charge_id].to_i > 0
    fee + monthly_rent_this_month
  end

  def balance_not_enough?
    @company.charge_company.balance - fee_for_batch_create_agents <= 0
  end

  def single_charge_balance_not_enough?
    ChargeCompany.find_by_company_id(@company.id).balance - fee_for_charge_agent <= 0
  end

  def monthly_rent_this_month
    params[:monthly_rent].to_f * DateTime.left_days_this_month_ratio
  end

  def create_nbms_company
    conn = Faraday.new(url: nbms_url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    begin
      res = conn.post do |req|
        req.url '/api/insert_user'
        req.headers['Content-Type'] = 'application/json'
        req.body = { tenant_id: @company.id, tenant_name: @company.name }.to_json
        req.options.timeout = 6
        req.options.open_timeout = 3
      end

      res_body = JSON.parse(res.body)

      logger.info res_body

      if res_body['code'] == 200
        flash[:notice] = "#{flash[:notice]}<br>同时在“号码管理系统”创建了一个企业账户，用户名：“#{@company.id}”，密码：“654321”。<br>企业可以登录“http://#{Settings.nbms.domain}:#{Settings.nbms.web_port}”管理本企业的主叫号码等信息。"
      elsif res_body['code'] == 412
        flash[:error] = "#{flash[:error]}<br>向“号码管理系统”创建企业账户时返回的错误信息：#{res_body['message']}"
      else
        flash[:error] = "#{flash[:error]}<br>向“号码管理系统”创建企业账户时，返回了未知的错误: #{res_body['message']}！请联系统一通信研发人员。"
      end
    rescue Exception => exception
      flash[:error] = "#{flash[:error]}<br>向“号码管理系统”创建企业账户时，遇到了异常：#{exception.to_s}！请联系统一通信研发人员。"
    end
  end

  def vacuum_nbms_data
    conn = Faraday.new(url: nbms_url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    begin
      res = conn.post do |req|
        req.url '/api/vacuumTenant'
        req.headers['Content-Type'] = 'application/json'
        req.body = { tenant_id: @company.id }.to_json
        req.options.timeout = 6
        req.options.open_timeout = 3
      end

      res_body = JSON.parse(res.body)

      logger.info res_body

      if res_body['code'] == 200
        flash[:notice] = "“号码管理系统” 中“#{@company.id}”的数据已清除。"
      else
        flash[:error] = "向“号码管理系统”发起企业下线清理时，遇到错误: #{res_body['message']} 请联系统一通信研发人员。"
      end
    rescue Exception => exception
      flash[:error] = "向“号码管理系统”发起企业下线清理时，遇到了异常：#{exception.to_s}！请联系统一通信研发人员。"
    end
  end

  def agent_id_taken?(agent_code_start, agent_count)
    @company.agents.exists?(id: ("#{@company.id}#{agent_code_start}".to_i.."#{@company.id}#{agent_code_start + agent_count - 1}".to_i).to_a)
  end
end
