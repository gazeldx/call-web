class Agent::CustomersController < SalesmanBaseController
  # skip_before_filter :check_session, only: [:new, :popup] # TODO: 去掉本行，因为现在不涉及Salesman和User混用了

  before_action :set_customer, only: [:edit, :update]

  include Customers, Search

  def popup
    @customer = current_company.customers.find_by_s1(replace_number_line_prefix(real_phone_number)) || current_company.customers.new(s1: replace_number_line_prefix(real_phone_number), act: Customer::ACT_CLUE)

    authorize(@customer, :popup?)

    render layout: 'bone'
  end

  def index
    @customers = base_query
  end

  def search
    @customers = base_query
    @customers = equal_search(@customers, company_columns.to_a.select { |column| column.select? }.map { |column| column.name.to_sym })
    search_updated_at
    search_created_at
    @customers = date_range_search(@customers, company_columns.to_a.select { |column| column.date? }.map { |column| column.name.to_sym })
    @customers = like_search(@customers, company_columns.to_a.select { |column| column.text? }.map { |column| column.name.to_sym })
    @customers = time_range_search(@customers, [:call_time])
    @customers = @customers.where('call_time is null') if params[:call_time_is_null] == 'true'
    render :index
  end

  def new
    @customer = current_company.customers.new(act: params[:act] || Customer::ACT_CUSTOMER)
  end

  def create
    @customer = current_company.customers.build(customer_params)
    @customer.salesman_id = session[:id]

    authorize(@customer, :manual_create?)

    if @customer.save
      if from_popup_page
        render text: "<script type='text/javascript'>window.close();</script>"
      else
        created_notice_and_redirect(@customer)
      end
    else # 因为手机号码是可以填写和修改的, 所以部分更新的逻辑会在此处处理
      customer = current_company.customers.find_by_s1(@customer.s1)

      if customer.present? && customer.state != Customer::STATE_OK
        customer.update(customer_params.merge({ state: Customer::STATE_OK, salesman_id: session[:id] }))

        created_notice_and_redirect(customer)
      else
        render :new
      end
    end
  end

  def edit
    authorize @customer

    set_return_to if request.referer.include?('customer')
  end

  def update
    authorize @customer

    original_act = @customer.act

    if @customer.update(customer_params.merge({ state: Customer::STATE_OK }.merge((@customer.salesman_id.nil? || current_company.company_config.switch_salesman?) ? { salesman_id: session[:id] } : {})))
      if from_popup_page
        render text: "<script type='text/javascript'>window.close();</script>"
      else
        flash[:notice] = t(:updated)
        if @customer.act != original_act
          flash[:notice] = "#{flash[:notice]}#{t(customer_or_clue_from_self + '.transfered')}"
          session[:return_to] = "#{customer_path}#{act_param_from_self}"
        end
        redirect_to  "/buyer/#{@customer.id}/edit#{act_param_from_self}"
      end
    else
      render :edit
    end
  end

  def call_phone
    if params[:customer_id].to_s.length >= 10 # 这表示这个客户是新客户, 数据库中不存在。customer_id是做过加密的。是加密了手机号码, 要还原后才能查出对应的客户。这是考虑到要隐藏号码企业的需求才这么做的(为简单起见, 非隐藏号码企业也同样操作)。
      if valid_phone_number?(params[:customer_id])
        phone = params[:customer_id]
      else
        phone = replace_number_line_prefix(Base64.decode64(URI.unescape(params[:customer_id])))
      end
      customer = Customer.find_by_s1(phone)
      customer = Customer.new(s1: phone) if customer.blank?
    else
      customer = Customer.find(params[:customer_id])
    end

    if current_user.agent_id.nil?
      render json: { result: '未绑定座席，不可点击呼叫' }, status: 403
      return
    end

    if $redis.hget("acdqueue:agent:#{current_user.agent_id}", 'status') != 'Ready'
      render json: { result: '您目前处于非就绪状态，不可呼叫' }, status: 403
      return
    end

    if !current_company.phone_numbers.agent_numbers.pluck(:number).include?(current_user.agent.show_number)
      render json: { result: "您的座席绑定的主叫号码“#{current_user.agent.show_number}”尚未被加入到贵公司的“座席主叫号码”名单中！本次呼叫未发起。" }, status: 403
      return
    end

    phone_number = PhoneNumber.find_by_number_and_company_id(current_user.agent.show_number, current_company.id)
    unless phone_number.present? && !phone_number.expired?
      render json: { result: "您的座席绑定的主叫号码“#{current_user.agent.show_number}”已经过了有效期。请完成对“主叫号码”的延期后，再尝试本次操作。" }, status: 403
      return
    end

    begin
      logger.info "callflow_api_webcall #{current_user.agent_id} #{customer.s1}"
      ::Publisher.publish('OutboundMessageExchange', 'all', "callflow_api_webcall #{current_user.agent_id} #{customer.s1}") if customer.s1.to_s.size >= 8
      customer.update_columns(call_time: Time.now) if customer.id.present?
      render json: { customer_id: customer.try(:id) }
    rescue Exception => e
      render json: { result: e.message }, status: 500
    end
  end

  private

  def base_query
    current_user.customers.ok.where(act: (params[:act] || Customer::ACT_CUSTOMER)).includes(:contacts).order('updated_at DESC').page(params[:page])
  end

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def from_popup_page
    /popup_customer/.match(request.referrer)
  end

  def created_notice_and_redirect(customer)
    flash[:notice] = t("#{customer_or_clue}.created")
    redirect_to "/buyer/#{customer.id}/edit#{act_param}"
  end

  def real_phone_number
    if params[:phone].start_with?(Customer::ENCODE_NUMBER_PREFIX)
      Base64.decode64(URI.unescape(params[:phone].sub(Customer::ENCODE_NUMBER_PREFIX, ''))) # 结合views/agent/console/_subscribe_popup_agent.erb, 可以更好的理解本处逻辑。此处解码最终将返回一个电话号码
    else
      params[:phone]
    end
  end
end
