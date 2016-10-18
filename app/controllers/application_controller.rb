class ApplicationController < ActionController::Base
  before_filter :check_logged

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :admin?, :user?, :salesman?, :current_user, :current_company, :parse_controller_path, :company_columns, :customer_columns, :clue_columns, :pure_clue_columns, :pure_customer_columns, :act_param, :act_clue?, :customer_or_clue, :customer_or_clue_reverse, :replace_number_line_prefix, :popup_customers_remain_count, :popup_customers_count, :ucweb_url, :nbms_url, :nbms_web_url, :hide_middle_digits, :refined_phone, :checkin_duration_and_average, :ratio, :max_package_records_cdrs_count, :audio_extension_file?

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def set_login_session
    session[:id] = @_person.id
    session[:username] = @_person.username
    session[:name] = @_person.name
    session[:admin] = true if @administrator
    session[:salesman] = true if @salesman

    set_company_config_session unless @administrator
  end

  def clear_session
    # session[:administrator_id] 是UC管理员以企业超级管理员身份登陆企业后台时，做的一个标识，值为Administrator表的id值。详见 admin/controllers/companies_controller#login_as_company_admin
    [:id, :username, :name, :admin, :salesman, :administrator_id, :return_to].each do |key|
      session[key] = nil
    end
  end

  def set_company_config_session
    session[:logo_path] = current_company.company_config.logo.small.url
    session[:web_name] = current_company.company_config.web_name
    session[:login_title_first] = current_company.company_config.login_title_first
    session[:login_title_second] = current_company.company_config.login_title_second
  end

  def set_return_to
    session[:return_to] = request.referer
  end

  def return_to
    return_to_path = session.delete(:return_to)
    if return_to_path.blank? # 加入这个判断的原因是如果用户点后退时，重新操作页面不至于报错。
      redirect_to root_path
    else
      redirect_to return_to_path
    end
  end

  def current_company
    if @_company.nil?
      @_company = current_user.company unless admin?
    end

    @_company
  end

  def current_user
    if @_person.nil?
      if admin?
        @_person = Administrator.find(session[:id])
      elsif salesman?
        @_person = Salesman.find(session[:id])
      else
        @_person = User.find(session[:id])
      end
    end

    @_person
  end

  def valid_phone_number?(number)
    number.to_s.match(/^1[0-9]{10}$/) || number.to_s.match(/^[0-9]{10,12}$/)
  end

  def invalid_numbers_notice
    if @invalid_numbers.present?
      lines_content = '<br>'
      @invalid_numbers.each { |invalid_number| lines_content += "第#{invalid_number[0]}行 #{invalid_number[1]}<br>" }
      flash[:notice] = "#{flash[:notice]}#{lines_content}号码格式不合规范。固定号码应为带区号（区号应以0开头，如：0512）的有效号码。<br> ** 共#{@invalid_numbers.size}个号码格式不合规范，没有被导入。"
    end
  end

  def customer_columns
    @_customer_columns = current_company.columns.active.where(target: [Column::TARGET_CUSTOMER, Column::TARGET_BOTH]).order(:created_at) if @_customer_columns.nil?

    @_customer_columns
  end

  def clue_columns
    @_clue_columns = current_company.columns.active.where(target: [Column::TARGET_CLUE, Column::TARGET_BOTH]).order(:created_at) if @_clue_columns.nil?

    @_clue_columns
  end

  # NOTICE: pure_clue_columns和pure_customer_columns不能删除，因为在页面customers/index.html.slim中用到了，搜索是搜不到的，因为用的是send的动态方法
  def pure_clue_columns
    @_pure_clue_columns = current_company.columns.active.where(target: Column::TARGET_CLUE).order(:created_at) if @_pure_clue_columns.nil?

    @_pure_clue_columns
  end

  def pure_customer_columns
    @_pure_customer_columns = current_company.columns.active.where(target: Column::TARGET_CUSTOMER).order(:created_at) if @_pure_customer_columns.nil?

    @_pure_customer_columns
  end

  def company_columns
    @_company_columns = current_company.columns.active.order(:created_at) if @_company_columns.nil?

    @_company_columns
  end

  def admin?
    session[:admin]
  end

  def user?
    logged? && !admin? && !salesman?
  end

  def salesman?
    session[:salesman]
  end

  def logged?
    session[:id]
  end

  def parse_controller_path(path)
    m = /\/.+?\//.match(path)
    if m
      m[0][0...m[0].size - 1]
    else
      path
    end
  end

  def exchange_created_at(candidates, target_object)
    matched_object = candidates.where('created_at < ?', target_object.created_at).order('created_at DESC').first

    unless matched_object.nil?
      target_object_created_at = target_object.created_at

      target_object.update_attribute('created_at', matched_object.created_at)

      matched_object.update_attribute('created_at', target_object_created_at)
    end
  end

  def replace_number_line_prefix(phone_number)
    prefixes = [current_company.manual_call_prefix, current_company.callback_prefix, current_company.task_prefix].reject { |prefix| prefix.strip == "" }
    if prefixes.blank?
      return phone_number
    else
      return phone_number.sub(/^(#{prefixes.join('|')})/, '')
    end
  end

  def popup_customers_remain_count
    current_company.company_config.import_popup_customers_count - current_company.customers.where(state: Customer::STATE_POPUP).count
  end

  def popup_customers_count
    current_company.customers.where(state: Customer::STATE_POPUP).count
  end

  def audio_extension_file?(file)
    file.end_with?('.wav') || file.end_with?('.mp3')
  end

  def ucweb_url
    "http://#{Settings.ucweb.domain}:#{Settings.ucweb.port}"
  end

  def nbms_url
    "http://#{Settings.nbms.host}:#{Settings.nbms.port}"
  end

  def nbms_web_url
    "http://#{Settings.nbms.domain}:#{Settings.nbms.web_port}"
  end

  def number_server_url
    "http://#{Settings.number_server.host}:#{Settings.number_server.port}"
  end

  def record_mixin_url
    "http://#{Settings.record_mixin_service.host}:#{Settings.record_mixin_service.port}"
  end

  def hide_middle_digits(phone)
    phone.to_s.hide_middle_digits
  end

  def refined_phone(phone)
    if session[:administrator_id].present? ||
      (!policy(:company_config2).salesman_can_see_numbers? && current_user.is_a?(Salesman)) ||
      (current_user.is_a?(User) && !policy(:user2).view_phone_number?)
      hide_middle_digits(phone)
    else
      phone
    end
  end

  def checkin_duration_and_average
    t('report_agent_daily.checkin_duration') + "/#{t('report_agent_daily.average_checkin_duration_short')}"
  end

  def ratio(numerator, denominator)
    "#{denominator > 0 ? ((numerator.to_f / denominator) * 100).round(1) : 0}%"
  end

  # def menus_authorized?(menu_name)
  #   if current_company.menus.map(&:name).include?(menu_name)
  #
  #   else
  #     user_not_authorized
  #   end
  # end

  # 用于导号时处理重复号码
  module DuplicateNumbers
    def remove_duplicate_task_phones(numbers)
      active_tasks_phones = current_company.active_tasks_phones
      duplicate_task_phones = numbers & active_tasks_phones
      flash[:notice] = "#{flash[:notice]}<br> ** 有#{duplicate_task_phones.size}个号码与号码库中的待拨打的号码重复，比如#{duplicate_task_phones.slice(0, 3).inspect}，系统已自动去掉这些重复号码。" unless duplicate_task_phones.blank?
      numbers - active_tasks_phones
    end

    def remove_duplicate_customer_numbers(numbers)
      duplicate_customer_phones = numbers & current_company.customers.ok.pluck(:s1)
      flash[:notice] = "#{flash[:notice]}<br> ** 有#{duplicate_customer_phones.size}个号码与销售线索（或客户名单）中号码重复，比如#{duplicate_customer_phones.slice(0, 3).inspect}，系统已自动去掉这些号码，以防对老客户重复拨打。" unless duplicate_customer_phones.blank?
      numbers - current_company.customers.ok.pluck(:s1)
    end
  end

  module Bundles
    def kind_to_path_hash
      { Bundle::KIND_AUTOMATIC => automatic_calls_path, Bundle::KIND_PREDICT => predict_calls_path, Bundle::KIND_IVR => ivr_calls_path, Bundle::KIND_KEYPRESS_TRANSFER => ivr_calls_path, Bundle::KIND_TIMEOUT_TRANSFER => ivr_calls_path, Bundle::KIND_KEYPRESS_GATHER => ivr_calls_path }
    end
  end

  module Customers
    def customer_params
      columns = []
      (1..Column::MAX_STRING_COUNT).each { |i| columns << "s#{i}".to_sym }
      (1..Column::MAX_ENUM_COUNT).each { |i| columns << "t#{i}".to_sym }
      (1..Column::MAX_DATE_COUNT).each { |i| columns << "d#{i}".to_sym }

      params.require(:customer).permit(columns.concat([:act, :salesman_id]))
    end

    def search_updated_at
      if params[:updated_at_start].present?
        @customers = @customers.where(updated_at: DateTime.parse("#{params[:updated_at_start]} #{params[:updated_at]['start(4i)']}:#{params[:updated_at]['start(5i)']}:#{params[:updated_at]['start(6i)']}")..DateTime.parse("#{params[:updated_at_end]} #{params[:updated_at]['end(4i)']}:#{params[:updated_at]['end(5i)']}:#{params[:updated_at]['end(6i)']}"))
      end
    end

    def search_created_at
      if params[:created_at_start].present?
        @customers = @customers.where(created_at: DateTime.parse("#{params[:created_at_start]} #{params[:created_at]['start(4i)']}:#{params[:created_at]['start(5i)']}:#{params[:created_at]['start(6i)']}")..DateTime.parse("#{params[:created_at_end]} #{params[:created_at]['end(4i)']}:#{params[:created_at]['end(5i)']}:#{params[:created_at]['end(6i)']}"))
      end
    end
  end

  def act_clue?
    params[:act] == "#{Customer::ACT_CLUE}" && (@customer.nil? || @customer.act_as_clue? || @customer.act_as_both?)
  end

  def act_param
    if act_clue?
      "?act=#{Customer::ACT_CLUE}"
    else
      ''
    end
  end

  def act_param_from_self
    if @customer.present? && @customer.act_as_clue?
      "?act=#{Customer::ACT_CLUE}"
    else
      ''
    end
  end

  def customer_or_clue
    if act_clue?
      'clue'
    else
      'customer'
    end
  end

  def customer_or_clue_reverse
    if act_clue?
      'customer'
    else
      'clue'
    end
  end

  def customer_or_clue_from_self
    if @customer.present? && @customer.act_as_clue?
      'clue'
    else
      'customer'
    end
  end
  
  def max_package_records_cdrs_count
    if SystemConfig.free_time?
      Cdr::MAX_PACKAGE_RECORDS_CDRS_COUNT_FREE_TIME
    else
      Cdr::MAX_PACKAGE_RECORDS_CDRS_COUNT
    end
  end

  module Cdrs
    def search_start_stamp
      if params[:start_stamp_day_begin].present?
        start_time = DateTime.parse("#{params[:start_stamp_day_begin]} #{params[:start_stamp_moment_begin]}:00")
        end_time = DateTime.parse("#{params[:start_stamp_day]} #{params[:start_stamp_moment]}:59")
        end_time = start_time + 7.days if (end_time - start_time > 7 && user? && controller_name == 'history_cdrs')
        @cdrs = @cdrs.where(start_stamp: start_time..end_time) if params[:callee_number].blank? # 因为被叫号码有索引, 所以查被叫时不加时间限制, 同时可改善用户体验
      else
        # Notice: 这种情况目前不会发生,因为 :start_stamp_day_begin 必定存在
        @cdrs = @cdrs.where(start_stamp: DateTime.parse(params[:start_stamp_day])..(DateTime.parse(params[:start_stamp_day]) + 24.hours))
      end
    end

    def search_duration
      if params[:duration].to_f > 0
        @cdrs = @cdrs.where('duration >= ?', params[:duration].to_f)
      end
    end

    def search_call_lose
      if params[:call_loss] == '1'
        @cdrs = @cdrs.where("bridge_stamp is null AND call_type=#{Cdr::CALL_TYPE_TASK}")
      elsif params[:call_loss] == '2'
        @cdrs = @cdrs.where("bridge_stamp is null AND call_type=#{Cdr::CALL_TYPE_INBOUND} AND group_id is not null")
      elsif params[:call_loss] == '0'
        @cdrs = @cdrs.where("bridge_stamp is not null OR call_type NOT IN (#{Cdr::CALL_TYPE_TASK}, #{Cdr::CALL_TYPE_INBOUND}) OR (call_type=#{Cdr::CALL_TYPE_INBOUND} AND group_id is null)")
      end
    end
  end

  module Search
    def like_search(list, columns)
      columns.reject { |input| params[input].blank? }.each do |column|
        list = list.where("#{column} LIKE ?", "%#{params[column]}%")
      end

      list
    end

    def equal_search(list, columns)
      columns.reject { |input| params[input].blank? }.each do |column|
        if params[column] == 'null'
          if column == :salesman_id
            list = list.where("salesman_id=0 or salesman_id is null")
          else
            list = list.where("#{column} is null")
          end
        else
          list = list.where(column => params[column])
        end
      end

      list
    end

    def date_range_search(list, columns)
      columns.reject { |column| params["#{column}_start"].blank? || params["#{column}_end"].blank? }.each do |column|
        list = list.where(column => DateTime.parse(params[column.to_s + '_start']).beginning_of_day..DateTime.parse(params[column.to_s + '_end']).end_of_day)
      end

      list
    end

    def time_range_search(list, columns)
      columns.reject { |column| params["#{column}_start"].blank? || params["#{column}_end"].blank? }.each do |column|
        list = list.where(column => DateTime.parse("#{params[column.to_s + '_start']} #{params[column]['start(4i)']}:#{params[column]['start(5i)']}:#{params[column]['start(6i)']}")..DateTime.parse("#{params[column.to_s + '_end']} #{params[column]['end(4i)']}:#{params[column]['end(5i)']}:#{params[column]['end(6i)']}"))
      end

      list
    end
  end

  module SearchTeam
    def search_team(reports)
      if params[:team_id].present?
        if params[:team_id] == 'null'
          salesman_ids = current_user.salesmen.where('team_id is null').pluck(:id)
        else
          salesman_ids = Salesman.where(team_id: params[:team_id]).pluck(:id)
        end
        reports = reports.where(salesman_id: salesman_ids)
      end

      reports
    end
  end

  private

  def redirect_path_for_logged
    admin? ? admin_root_path : root_path
  end

  def check_logged
    if !logged?
      redirect_to login_path
    elsif admin?
      if controller_path == 'news'
        # Do nothing
      else
        redirect_to admin_root_path
      end
    end
  end

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    flash[:error] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
    # redirect_to(request.referrer || root_path)
    redirect_to redirect_path_for_logged
  end
end
