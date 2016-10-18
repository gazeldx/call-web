class CustomersController < BaseController
  before_action :set_customer, only: [:edit, :update, :destroy]

  include Customers, Search, Bundles, DuplicateNumbers

  def index
    base_query

    order_by

    @customers = @customers.includes(:salesman, :contacts).page(params[:page])
  end

  def search
    base_query

    search_body

    order_by

    if params[:target_method] == 'export'
      authorize(:user2, :export_customers?)
      max_count = 20000
      if !SystemConfig.free_time? && @customers.count > Customer::MAX_EXPORT_COUNT_ON_BUSY_TIME # 这里是双重保护了下, 页面上已经做了控制了。
        send_data(t(:operate_at_free_time).encode('gbk', 'utf-8'), filename: "客户数量在#{Customer::MAX_EXPORT_COUNT_ON_BUSY_TIME}条以内可以直接导出。本次要导出的客户数超过了#{Customer::MAX_EXPORT_COUNT_ON_BUSY_TIME}条，请分多次导出，每次控制客户数在#{Customer::MAX_EXPORT_COUNT_ON_BUSY_TIME}条以内；或者#{t(:operate_at_free_time)}.csv")
      elsif @customers.count > max_count
        send_data(t('customer.export_max_content', w: max_count).encode('gbk', 'utf-8'), filename: "#{t('customer.export_max_title', w: max_count)}.csv")
      else
        @customers = @customers.includes(:salesman)
        export_customers
      end
    elsif params[:target_method] == 'package_records'
      package_records
      redirect_to "#{customers_path}#{act_param}"
    elsif params[:target_method] == 'assign_to_salesman'
      do_assign_to_salesman
      redirect_to "#{customers_path}#{act_param}" # redirect_to request.referer # TODO: 这种方式可以跳转到原页面, 但会报'nginx 502 bad gateway'错误. 如果可以解决就更好了, 不解决问题没什么关系.
    elsif params[:target_method] == 'batch_delete' && current_user.admin?
      max_deleted_count = 10000
      if @customers.count > max_deleted_count
        send_data(t('customer.batch_delete_max_content', w: max_deleted_count).encode('gbk', 'utf-8'), filename: "#{t('customer.batch_delete_max_title', w: max_deleted_count)}.csv")
      else
        batch_delete
        redirect_to "#{customers_path}#{act_param}"
      end
    elsif params[:target_method] == 'switch_act'
      switch_act
      redirect_to "#{customers_path}#{act_param}"
    else
      @customers = @customers.includes(:salesman, :contacts).page(params[:page])
      render :index
    end
  end

  def new
    @customer = current_company.customers.new(act: params[:act] || Customer::ACT_CUSTOMER)
  end

  def create
    @customer = current_company.customers.build(customer_params)

    authorize(@customer, :manual_create?)
    
    if @customer.save
      created_notice_and_redirect(@customer)
    else # 因为手机号码是可以填写和修改的, 所以部分更新的逻辑会在此处处理
      customer = current_company.customers.find_by_s1(@customer.s1)

      if customer.present? && customer.state != Customer::STATE_OK
        customer.update(customer_params.merge({ state: Customer::STATE_OK }))

        created_notice_and_redirect(customer)
      else
        render :new
      end
    end
  end

  def edit
    authorize @customer

    set_return_to if request.referer.include?('customers')
  end

  def update
    authorize @customer

    original_act = @customer.act

    if @customer.update(customer_params)
      flash[:notice] = t(:updated)
      if @customer.act != original_act
        flash[:notice] = "#{flash[:notice]}#{t(customer_or_clue_from_self + '.transfered')}"
        session[:return_to] = "#{customers_path}#{act_param_from_self}"
      end
      redirect_to "/buyers/#{@customer.id}/edit#{act_param_from_self}"
    else
      render :edit
    end
  end

  def destroy
    @customer.update_attribute(:state, Customer::STATE_DELETED)

    render json: @customer.as_json
  end

  def import
  end

  def do_import
    save_customers_and_redirect
  end

  def download_export_customers_template
    send_data(customer_template_content.encode('gbk', 'utf-8'), filename: "Customers_Template.csv")
  end

  def set_vip_level
    # TODO: Authorize
    customer = Customer.find(params[:customer_id])

    next_vip = Vip.next(customer)

    customer.update_attributes!(vip_id: next_vip.try(:id))

    RedisHelp.set_customer_vip(customer)

    render json: next_vip.as_json.to_h.merge(customer_id: customer.id)
  end

  def do_assign_to_salesman
    if params['assign_to_null'].present?
      flash[:notice] = "#{flash[:notice]}#{t('customer.assign_to_null_salesman_success', count: Customer.where(id: assigned_customer_ids).update_all(salesman_id: nil, updated_at: Time.now))}<br>"
    else
      assigned_salesmen = current_company.salesmen.find(params['assigned_salesman_ids'])
      if params[:count].to_i > 0 && assigned_salesmen.count > 0
        customer_ids = assigned_customer_ids
        each_salesman_customers_count = customer_ids.size / assigned_salesmen.count
        each_salesman_customers_count = 1 if each_salesman_customers_count == 0

        assigned_salesmen.each do |salesman|
          salesman_customers_ids = customer_ids.sample(each_salesman_customers_count)
          customer_ids -= salesman_customers_ids
          unless salesman_customers_ids.blank?
            updated_count = Customer.where(id: salesman_customers_ids).update_all(salesman_id: salesman.id, updated_at: Time.now)
            flash[:notice] = "#{flash[:notice]}#{t('customer.assign_to_salesman_success', count: updated_count, salesman_name: salesman.name)}<br>"
          end
        end
      end
    end
    logger.warn "#{current_company.name_and_id} 分配人: #{session[:id]} #{current_user.name}, #{flash[:notice]}"
  end

  def package_records
    return if @customers.count > Customer::MAX_PACKAGE_RECORDS_CUSTOMERS_COUNT

    # TODO: 这里运行没问题后要去掉logger.
    logger.warn "history_cdrs size=#{Cdr.records_map(cdrs_conditions_for_packaging(current_company.history_cdrs)).size}"
    logger.warn "        cdrs size=#{Cdr.records_map(cdrs_conditions_for_packaging(current_company.cdrs)).size}"
    records_map = Cdr.handle_dup_record_name((Cdr.records_map(cdrs_conditions_for_packaging(current_company.history_cdrs)) + Cdr.records_map(cdrs_conditions_for_packaging(current_company.cdrs))).uniq)
    logger.warn " records_map size=#{records_map.size}"

    if records_map.blank?
      flash[:error] = "未搜索到任何录音。"
      return
    end

    record_package = current_company.record_packages.create!(creator_id: session[:id], title: params[:title])

    begin
      message = { package_file_name: record_package.package_file_name,
                  records_map: records_map }
      logger.warn "发送打包客户名单录音消息: #{message}"
      ::Publisher.directPublish('sneakers', 'package_records', message)

      RedisHelp.increase_package_records_times(current_company.id)
    rescue Exception => e
      logger.error "发送录音打包消息失败，原因是: #{e.message}。消息为: #{message}"
    end

    flash[:notice] = "正在为您打包录音，如果录音数量较多，请稍等片刻再下载。点此 ==> “<a href='#{download_records_packages_path}'>#{t('record_package.download')}</a>”。"
  end

  def do_test_numbers
    params[:numbers].split(' ').each do |number|
      if number.size >= 10 && number.size <= 12
        customer = current_company.customers.find_by_s1(number)

        task_phone = TaskPhone.where(task_id: Task.where(bundle_id: current_company.bundles.pluck(:id), state: [Task::STATE_INIT, Task::STATE_READY, Task::STATE_RUNNING, Task::STATE_PAUSED, Task::STATE_STASHED]).pluck(:id),
                                     phone: number).first

        if customer.present?
          flash[:notice] = "#{flash[:notice]}#{customer.s1}可以弹屏，目前该号码被保存在了“#{t('customer.act_' + customer.act.to_s)}”中，状态为“#{t('customer.state_' + customer.state.to_s)}”#{'（是隐藏的，在销售线索中搜索不出来）' if [Customer::STATE_POPUP, Customer::STATE_DELETED].include?(customer.state)}，信息（#{customer.inspect.sub('#<Customer ', '').sub('>', '）')}；"
        else
          flash[:notice] = "#{flash[:notice]}#{number}弹屏信息为空，因为没有被导入；"
        end

        if task_phone.present?
          flash[:notice] = "#{flash[:notice]}该号码存在于号码库“#{task_phone.task.name}”中；"
        else
          flash[:notice] = "#{flash[:notice]}该号码不存在于任何号码库中；"
        end
      else
        flash[:notice] = "#{flash[:notice]}#{number}无法弹屏，因为号码格式不合规范；"
      end

      flash[:notice] = "#{flash[:notice]}<br>"
    end

    render :test_numbers
  end

  private

  def base_query
    @customers = current_user.customers.where(act: (params[:act] || Customer::ACT_CUSTOMER))
  end

  def search_body
    @customers = equal_search(@customers, [:salesman_id] + company_columns.to_a.select { |column| column.select? }.map { |column| column.name.to_sym })
    search_updated_at
    search_created_at
    @customers = date_range_search(@customers, company_columns.to_a.select { |column| column.date? }.map { |column| column.name.to_sym })
    @customers = like_search(@customers, company_columns.to_a.select { |column| column.text? }.map { |column| column.name.to_sym })
  end

  def order_field
    if params[:orderBy].present?
      if params[:orderBy].end_with?('_desc')
        return { params[:orderBy].slice(0, params[:orderBy].size - '_desc'.size) => :desc }
      else
        return { params[:orderBy].slice(0, params[:orderBy].size - '_asc'.size) => :asc }
      end
    else
      params[:orderBy] = 'updated_at_desc'
      return { updated_at: :desc }
    end
  end

  def order_by
    @customers = @customers.order(order_field)
  end

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def line_to_customer(line)
    customer_id = @phone_map[line[:s1]].try(:[], :id)

    if customer_id.present?
      hash_more = { create_or_update: :update, id: customer_id }
    else
      hash_more = { create_or_update: :create }
    end

    return line.merge(hash_more)
  end

  def handle_line(customer_values, company_options, error_line)
    customer_hash = {}

    begin
      @appeared_columns.each_with_index do |column, i|
        translated_value = column_value_translated(company_options, column, customer_values[i])

        if column.name == 's1'
          translated_value = translated_value.gsub(/[^0-9]/, '')
          unless valid_phone_number?(translated_value)
            @invalid_numbers << [error_line, translated_value]
            return {}
          end
        end

        customer_hash.merge!({ column.name.to_sym => translated_value })
      end

      return customer_hash
    rescue => e
      logger.warn e.message
      return nil
    end
  end

  def customers_from_upload
    require 'csv'

    uploader = CustomerUploader.new

    logger.warn "====#{Time.now.strftime(t(:time_format))}  #{current_company.id} 导入人: #{session[:id]} #{current_user.name}, customers_from_upload start ===="
    begin
      uploader.cache!(params[:customers_file])

      customers_file = CSV.open(uploader.file.instance_variable_get(:@file), encoding: 'gbk:utf-8', quote_char: "\x00") # 这里用一个永远不存在的字符"\x00"替代英文双引号，使得双引号不被作为quote_char处理，并且如果双引号里面有英文逗号，将被认为是分隔符。
    rescue Exception => e
      flash[:error] = "#{e.message} #{e.class}"
      return []
    end
    logger.warn "====#{Time.now.strftime(t(:time_format))} #{current_company.id} customers_from_upload file uploaded ===="

    lines = []
    valid_customers = { for_create: [], for_update: [] }
    error_line = 0
    @invalid_numbers = []

    begin
      company_options = current_company.options.to_a

      customers_file.each_with_index do |line, i|
        error_line = i + 2

        if i == 0
          handle_first_line(line)

          break if flash[:error]
        else
          add_to_lines(lines, handle_line(line, company_options, i + 1))
        end
      end
    rescue Encoding::UndefinedConversionError => exception
      flash[:error] = "#{error_line}行有非法字符，请去掉非法字符后再导入。<br>具体报错信息为：#{exception.message} #{exception.class}"
      return []
    rescue Exception => exception
      flash[:error] = "#{error_line}行格式不合规范，请修改后再导入。<br>具体报错信息为：#{exception.message} #{exception.class.to_s}"
      return []
    end

    @phone_map = Hash[current_company.customers.where(s1: lines.map { |line| line[:s1] }).pluck(:s1, :id, :act, :state).map { |customer| [customer[0], { id: customer[1], act: customer[2], state: customer[3] }] }] # 本行返回值如: {"13811129328"=>{ id: 153216, act: 1, state: 1 }}

    lines.each do |line|
      add_to_valid_customers(valid_customers, line_to_customer(line))
    end

    logger.warn "====#{Time.now.strftime(t(:time_format))}  #{current_company.id} customers_from_upload calc dup numbers in file ===="
    for_create_numbers_before = valid_customers[:for_create].clone.map { |customer| customer[:s1] }
    for_create_count_before = valid_customers[:for_create].size
    for_update_numbers_before = valid_customers[:for_update].clone.map { |customer| customer[:s1] }
    for_update_count_before = valid_customers[:for_update].size
    @duplicate_numbers_sample = ''
    [:for_create, :for_update].each do |for_what|
      valid_customers[for_what].uniq! { |customer| customer[:s1] }
      if for_what == :for_create
        @for_create_duplicate_count = for_create_count_before - valid_customers[:for_create].size
        if @for_create_duplicate_count > 0 && for_create_numbers_before.size < 3000
          @duplicate_numbers_sample = for_create_numbers_before.detect { |number| for_create_numbers_before.count(number) > 1 }
        end
      else
        @for_update_duplicate_count = for_update_count_before - valid_customers[:for_update].size
        if @for_update_duplicate_count > 0 && @duplicate_numbers_sample.empty? && for_update_numbers_before.size < 3000
          @duplicate_numbers_sample = for_update_numbers_before.detect { |number| for_update_numbers_before.count(number) > 1 }
        end
      end
    end

    logger.warn "====#{Time.now.strftime(t(:time_format))} #{current_company.id} customers_from_upload valid_customers filtered ===="
    valid_customers
  end

  def save_customers
    customers = customers_from_upload

    unless flash[:error]
      if (customers[:for_create].size + current_company.customers.ok.count > current_company.company_config.import_customers_count) && !popup_import_customers?
        flash[:error] = t('pundit.customer_policy.create?', max_count: current_company.company_config.import_customers_count)
      elsif customers[:for_update].size > Customer::MAX_UPDATE_COUNT && !popup_import_customers? && !add_only?
        flash[:error] = t('pundit.customer_policy.update_too_many?', w: Customer::MAX_UPDATE_COUNT)
      elsif popup_import_customers? && customers[:for_create].size > popup_customers_remain_count
        flash[:error] = "用于弹屏的隐藏的销售线索数量已达上限：#{current_company.company_config.import_popup_customers_count}个。本次操作被拒绝。"
      else
        batch_insert_customers(customers[:for_create])

        for_update = add_only? ? state_popup_and_deleted_customers(customers[:for_update]) : customers[:for_update] # 如果state是已经删除或者是弹屏导入状态, 在从销售线索或客户名单页面导入时, 即使add_only? == true, 也应该显示出来。
        batch_update_customers(for_update)

        batch_create_task_phones(customers) if popup_import_customers?
      end
    end

    customers
  end

  def batch_insert_customers(customers)
    logger.warn "==== #{current_company.id} batch_insert_customers start ===="
    unless customers.blank?
      unless current_user.admin?
        team = Team.create(name: )
        Salesman.create(username: "#{Salesman::USER_UNIQUE_PREFIX}#{current_user.id}",
                        name: "#{Salesman::USER_UNIQUE_PREFIX}#{current_user.id}",
                        passwd: rand(999999999999),
                        team_id: "TODO") if current_user.self_salesman.blank?
      end

      sql_prefix = "INSERT INTO customers(company_id,#{@appeared_columns.map(&:name).join(',')},created_at,updated_at,act,state) VALUES "
      sql_arr = []

      customers.each do |customer|
        sql_arr << "(#{current_company.id},#{@appeared_columns.map do |column|
          (customer[column.name.to_sym].blank? || customer[column.name.to_sym] == '-') ? "null" : "'#{customer[column.name.to_sym]}'"
        end.join(',')},'#{1.second.ago.to_s[0..18]}','#{1.second.ago.to_s[0..18]}',#{act_clue? ? Customer::ACT_CLUE : Customer::ACT_CUSTOMER},#{params[:state] || Customer::STATE_OK})"
      end

      begin
        sql_arr.each_slice(500) do |sql_elements|
          ActiveRecord::Base.connection.execute(sql_prefix + sql_elements.join(','))
        end
      rescue Exception => e
        logger.warn "customer_controller#batch_insert_customers failed. @company_id= #{current_company.id}. Exception is #{e.message}"
      end
    end
    logger.warn "==== #{current_company.id} batch_insert_customers end ===="
  end

  def batch_update_customers(customers)
    logger.warn "==== #{current_company.id} batch_update_customers start ===="
    sql_arr = []
    state_part = popup_import_customers? ? '' : ",state=#{Customer::STATE_OK}" # 导入时，如果在线索或客户名单中导入，要把已经deleted的和popup only的state update to OK
    updated_at_part = ",updated_at='#{1.second.ago.to_s[0..18]}'"

    customers.each do |customer|
      sql_arr << "UPDATE customers SET #{@appeared_columns.reject { |column| customer[column.name.to_sym].blank? }.map do |column| # 文件中填入内容为空，表示不做修改。此处通过reject()实现
        if customer[column.name.to_sym] == '-' # 文件中填入内容为'-'才表示修改内容为空值！
          column_value = 'null'
        elsif column.select?
          column_value = customer[column.name.to_sym]
        else
          column_value = "'#{customer[column.name.to_sym]}'"
        end

        "#{column.name}=#{column_value}"
      end.join(',')}#{state_part}#{updated_at_part}#{act_part_of_update(customer[:s1])} WHERE id=#{customer[:id]};"
    end

    begin
      sql_arr.each_slice(500) do |sql_elements|
        ActiveRecord::Base.connection.execute(sql_elements.join(''))
      end
    rescue Exception => e
      logger.warn "customer_controller#batch_update_customers failed. @company_id= #{current_company.id}. Exception is #{e.message}"
    end

    logger.warn "==== #{current_company.id} batch_update_customers end ===="
  end

  def save_customers_and_redirect
    prepare_task if popup_import_customers?

    customer_count_before_import = current_company.customers.count

    saved_customers = save_customers

    unless flash[:error]
      @customer_count = ActiveRecord::Base.connection.execute("select count(1) as customer_count from customers where company_id=#{current_company.id}").to_a.first['customer_count'].to_i
      invalid_numbers_notice
      duplicate_notice
      if add_only? && @customers_updated.size > 0
        flash[:notice] = "#{flash[:notice]}<br>#{t('customer.import_customers_add_only_finished', created_count: @customer_count - customer_count_before_import, w: t("#{customer_or_clue}.self"), updated_count: @customers_updated.size)}"
      else
        flash[:notice] = "#{flash[:notice]}<br>#{t('customer.import_customers_finished', created_count: @customer_count - customer_count_before_import, w: t("#{customer_or_clue}.self"), updated_count: (add_only? ? @customers_updated.size : saved_customers[:for_update].size))}"
      end
    end

    if popup_import_customers?
      update_phone_count
      redirect_to kind_to_path_hash[@task.bundle.kind]
    else
      redirect_to "#{customers_path}#{act_param}"
    end
  end

  def customer_template_content
    company_columns.map do |column|
      if column.select?
        "#{column.title}(#{column.options.map(&:text).join('|')})"
      else
        column.title
      end
    end.join(',') + "\n（提示：请务必删掉本次导入不涉及的列，以防止有价值的数据被误替换。本行提示也要删掉。）\n"
  end

  def handle_first_line(first_line)
    @appeared_columns = []

    first_line.each do |column_title|
      unless column_title.present?
        flash[:error] = t('customer.first_line_column_not_exist', w: column_title)
        break
      end

      column = current_company.columns.find_by_title(column_title.sub(/\(.*\)/, ''))

      unless column.present?
        flash[:error] = t('customer.first_line_column_not_exist', w: column_title)
        break
      end

      @appeared_columns << column
    end
  end

  def column_value_translated(company_options, column, original_value)
    original_value = original_value.to_s.strip

    if original_value == '-'
      return original_value
    elsif column.select?
      company_options.find { |option| option.text == original_value }.try(:value)
    elsif column.date?
      DateTime.transfer_string_to_date(original_value)
    else
      if column.name == 's2' and original_value.blank?
        original_value = I18n.t('customer.no_name_import')
      end

      original_value.blank? ? nil : original_value[0..254].gsub(/(delete|insert|update|drop|truncate|database|'|"|\^|~|`|&|\*|rm)/i, '').strip
    end
  end

  def add_to_valid_customers(valid_customers, customer)
    if customer.present?
      if customer[:create_or_update] == :update
        valid_customers[:for_update] << customer
      elsif customer[:create_or_update] == :create
        valid_customers[:for_create] << customer
      end
    end
  end

  def add_to_lines(lines, customer)
    lines << customer if customer.present?
  end

  def popup_import_customers?
    params[:state] == Customer::STATE_POPUP.to_s # 返回值为true意味着是在任务号码库中导入弹屏用的客户信息, 这种情况需要处理号码库相关的数据
  end

  def duplicate_notice
    flash[:notice] = "#{flash[:notice]}<br> ** 有#{@for_create_duplicate_count + @for_update_duplicate_count}行号码在文件中重复出现（#{@duplicate_numbers_sample.present? ? "比如\"#{@duplicate_numbers_sample}\"" : '由于号码行数较多，系统就不给出重复号码示例了'}），系统已自动去掉这些重复行。" if @for_create_duplicate_count + @for_update_duplicate_count > 0
  end

  def prepare_task
    if params[:task_id].present?
      @task = Task.find(params[:task_id])
    else
      @task = Bundle.find(params[:bundle_id]).tasks.build(creator_id: session[:id],
                                                          name: params[:task][:name],
                                                          remark: params[:task][:remark])
      authorize(@task, :create?)

      unless @task.valid?
        @task.name = "#{@task.name}.#{(100..999).sample}"
      end

      @task.save!
    end
  end

  def update_phone_count
    phone_count_before_import = @task.phone_count

    @task.phone_count = ActiveRecord::Base.connection.execute("select count(1) as phone_count from task_phones where task_id=#{@task.id}").to_a.first['phone_count'].to_i
    @task.save

    flash[:notice] = "#{flash[:notice]}</br>" + t('task.import_numbers_finished', w: @task.phone_count - phone_count_before_import) unless flash[:error]
  end

  def batch_create_task_phones(customers)
    logger.warn "==== #{current_company.id} batch_create_task_phones start ===="
    unless customers[:for_create].blank? and customers[:for_update].blank?
      sql_task_phones_prefix = 'INSERT INTO task_phones(task_id, phone) VALUES'
      sql_task_phones_arr = []

      task_phones_tobe_created(customers).shuffle!.each do |number|
        sql_task_phones_arr << "(#{@task.id},'#{number}')"
      end

      begin
        sql_task_phones_arr.each_slice(500) do |sql_elements|
          ActiveRecord::Base.connection.execute(sql_task_phones_prefix + sql_elements.join(','))
        end
      rescue Exception => e
        logger.warn "Save task phones when save customers failed. task_id= #{@task.id}. Exception is #{e.message}"
      end
    end
    logger.warn "==== #{current_company.id} batch_create_task_phones end ===="
  end

  def task_phones_tobe_created(customers)
    numbers = (params[:reject_customers] == 'true' ? customers[:for_create] : customers[:for_create] + customers[:for_update]).map do |customer|
      customer[:s1]
    end

    numbers = remove_duplicate_task_phones(numbers)

    if popup_import_customers? && params[:include_customers] == 'true'
      return numbers
    else
      return remove_duplicate_customer_numbers(numbers)
    end
  end

  def created_notice_and_redirect(customer)
    flash[:notice] = t("#{customer_or_clue}.created")
    redirect_to "/buyers/#{customer.id}/edit#{act_param}"
  end

  def export_customers
    send_data(customers_content, filename: "#{act_clue? ? 'SalesClue' : 'Customers'}#{Time.now.strftime(t(:time_digits))}.csv") if session[:administrator_id].nil?
  end

  def customers_content
    csv_array = []
    csv_array << company_columns.map { |column| column.title }.push(t(:salesman_)).push(t('salesman.id')).push(t(:created_at)).push(t(:updated_at)).join(',')

    @company_options = {}
    current_company.options.each { |option_group| @company_options["t#{option_group.tid}_____#{option_group.value}"] = option_group.text }

    start = Time.now
    @customers.each { |customer| csv_array << a_customer_line(customer) }
    logger.warn "~~~~~~ #{Time.now.strftime(t(:time_format))} 生成Customers.csv结束. 客户数:#{@customers.count}, 总耗时: #{(Time.now - start).round(2)}秒 ~~~~~~"
    begin
      csv_array.join("\n").encode('gbk', 'utf-8')
    rescue Encoding::UndefinedConversionError => e
      logger.info "#{current_company.id} 导出客户名单时发生异常：#{e.message} #{e.class}。应该是特殊字符编码导致的。 #{params.inspect}"

      csv_array.join("\n")
    end
  end

  def a_customer_line(customer)
    company_columns.map do |column|
      value = customer.try(column.name.to_sym) || ''

      if column.text?
        value.gsub(/[",]/, ' ') # 去掉双引号和,
      elsif column.select?
        @company_options["#{column.name}_____#{value}"] # 本句纯粹是为了提升效率而写的,原本写法是: column.options.find_by_value(value).try(:text)
      elsif column.date?
        value.strftime(t(:date_format_)) if value.present?
      end
    end.push(customer.salesman.try(:name)).push(customer.salesman_id).push(customer.created_at.strftime(t(:time_format_simple))).push(customer.updated_at.strftime(t(:time_format_simple))).join(',')
  end

  def batch_delete
    authorize(:customer2, :batch_delete?)

    deleted_count = @customers.count
    logger.warn ">>>> 企业#{current_company.id}正在批量删除customers表和contacts表数据。本次将删除共#{deleted_count}条customers数据 >>>>"

    @customers.update_all(state: Customer::STATE_DELETED, updated_at: Time.now)

    flash[:notice] = t('customer.batch_delete_success', w: deleted_count)
    logger.warn ">>>> 企业批量删除customers结束。 >>>>"
  end

  def switch_act
    switched_count = @customers.count
    logger.warn ">>>> 企业#{current_company.id}正在批量转换customers表act状态。本次共有#{switched_count}条customers数据转换状态 >>>>"

    @customers.update_all(act: (act_clue? ? Customer::ACT_CUSTOMER : Customer::ACT_CLUE), updated_at: Time.now)

    flash[:notice] = t('customer.switch_act_success', count: switched_count, w: (act_clue? ? t('customer.self') : t('clue.self')))
    logger.warn ">>>> 企业批量转换customers表act状态结束。 >>>>"
  end

  def act_part_of_update(phone_number)
    if popup_import_customers?
      ''
    else
      original_customer = @phone_map[phone_number]
      params_act = params[:act].blank? ? Customer::ACT_CUSTOMER : Customer::ACT_CLUE
      logger.info("======== phone is #{original_customer[:s1]}")
      logger.info "params_act != original_customer[:act] is #{params_act != original_customer[:act]} #{params_act} #{original_customer[:act]}"
      logger.info "params_act == #{Customer::ACT_CUSTOMER} is #{params_act == Customer::ACT_CUSTOMER}"
      if params_act != original_customer[:act]
        if params_act == Customer::ACT_CUSTOMER
          ",act=#{Customer::ACT_CUSTOMER}"
        else
          if original_customer[:state] == Customer::STATE_DELETED
            ",act=#{Customer::ACT_CLUE}"
          end
        end
      end
    end
  end

  def state_popup_and_deleted_customers(customers)
    customers_hash = {}
    customers.each { |customer| customers_hash.merge!({ customer[:s1] => customer }) }
    ok_phones = current_company.customers.ok.pluck(:s1)
    customers_phones = customers.map { |customer| customer[:s1] }
    updated_phones = customers_phones - (ok_phones & customers_phones)
    @customers_updated = []
    updated_phones.each { |phone| @customers_updated << customers_hash[phone] }
    @customers_updated
  end

  def assigned_customer_ids
    if params[:assign_type] == 'order'
      @customers.limit(params[:count].to_i).pluck(:id)
    else
      @customers.pluck(:id).sample(params[:count].to_i)
    end
  end

  def add_only?
    params[:add_only] == 'true'
  end

  def cdrs_conditions_for_packaging(cdrs)
    cdrs.where(callee_number: @customers.pluck(:s1)).where('duration > 0')
  end
end
