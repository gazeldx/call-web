class TasksController < BaseController
  include Bundles, DuplicateNumbers

  before_action :set_bundle, only: [:new, :create, :edit, :update, :import_numbers, :do_import_numbers, :export_numbers]
  before_action :set_task, only: [:edit, :update, :destroy, :start, :pause, :stash, :resume, :import_numbers, :do_import_numbers, :export_numbers]

  def history
    @tasks = Task.where(bundle_id: current_user.bundles.pluck(:id)).where(state: [Task::STATE_STASHED, Task::STATE_FINISHED]).includes(:bundle).order('updated_at DESC').page(params[:page])
  end

  def new
    @task = @bundle.tasks.build

    authorize(@task, :create?)
  end

  def edit
    authorize(@task, :update?)
  end

  def create
    @task = @bundle.tasks.build(task_params.merge(creator_id: session[:id]))

    if import_by_number_segment?
      @task.name = "从#{params[:start_phone]}起的#{params[:phone_count]}个号码"
    elsif import_automatically?
      @task.name = "#{@task.name}#{params[:mobile_operator]}#{rand(999999)}"
    end

    authorize @task

    if @task.save
      save_phones_and_redirect
    else
      render :new
    end
  end

  def import_numbers
    authorize @task
  end

  def do_import_numbers
    authorize(@task, :import_numbers?)

    save_phones_and_redirect
  end

  def export_numbers
    authorize(@task, :export?)

    send_data(task_phones_content.encode('gbk', 'utf-8'), filename: "phones_#{@task.name}.csv")
  end

  def update
    authorize(@task, :update?)

    if @task.update(task_params)
      redirect_to kind_to_path_hash[@bundle.kind], notice: t('task.updated')
    else
      render :edit
    end
  end

  def stash
    authorize @task

    @task.stash

    redirect_to kind_to_path_hash[@task.bundle.kind], notice: t('task.stashed')
  end

  def resume
    authorize @task

    task_phones_count_before = @task.task_phones.count
    @task.resume
    duplicated_numbers_count = task_phones_count_before - @task.task_phones.count
    notice = duplicated_numbers_count > 0 ? t('task.resumed', task_name: @task.name, duplicated_numbers_count: duplicated_numbers_count) : t('task.resumed_and_no_reject', task_name: @task.name)
    redirect_to kind_to_path_hash[@task.bundle.kind], notice: notice
  end

  # TODO: 如果发现task.bundle下已经不存在任何task了,应该删除bundle. 否则有bundle垃圾数据存在; 之前的bundle垃圾数据: bundle.tasks.count == 0 && bundle.active == false 应该被清理掉.
  def destroy
    authorize @task

    @task.destroy

    redirect_to kind_to_path_hash[@task.bundle.kind] + '/history', notice: t('task.deleted')
  end

  def start
    authorize(@task, :start?)

    if @task.init?
      @task.update_attributes(state: Task::STATE_READY, started_at: Time.now, created_at: Time.now)
    else
      @task.update_attributes(started_at: Time.now)
    end

    begin
      ::Publisher.directPublish('OutboundRequestExchange', 'OutboundRequest', { messageId: 1001, taskId: @task.id, companyId: @task.bundle.company.id })

      render json: { result: t('task.start_message_sent') }
    rescue Exception => e
      render json: { result: e.message }, status: 500
    end
  end

  def pause
    authorize(@task, :pause?)

    begin
      # ::Publisher.directPublish('OutboundRequestExchange', "bundle_#{@task.bundle.id}", { messageId: 1002, taskId: @task.id, companyId: @task.bundle.company.id })
      # 根据张林剑的要求，暂时先还是用"OutboundRequest"作为routing_key。后期再考虑集群。
      ::Publisher.directPublish('OutboundRequestExchange', "OutboundRequest", { messageId: 1002, taskId: @task.id, companyId: @task.bundle.company.id })

      render json: { result: t('task.pause_message_sent') }
    rescue Exception => e
      render json: { result: e.message }, status: 500
    end
  end

  def task_kind
    kind_to_path_hash.key(parse_controller_path(request.path_info)).to_i
  end

  private

  def parse_phone_number(line, index)
    phone = line.gsub(/[^0-9]/, '')
    if valid_phone_number?(phone)
      return phone
    else
      @invalid_numbers << [index, phone]
      return nil
    end
  end

  def set_task
    @task = Task.find(params[:id])
  end

  def set_bundle
    @bundle = Bundle.find(params[:bundle_id])
  end

  def task_params
    params.require(:task).permit(:name, :remark)
  end

  def save_task_phones
    phones = valid_phones

    unless phones.blank?
      numbers = remove_duplicate_task_phones(phones)

      numbers = remove_duplicate_customer_numbers(numbers)

      numbers.shuffle!

      batch_insert_phones(numbers)
    end
  end

  def phones_from_upload
    uploader = PhoneUploader.new

    begin
      uploader.cache!(params[:task_phones_file])

      phones_file = uploader.file.read
    rescue Exception => e
      flash[:error] = e.message
      return []
    end

    valid_phones = []
    @invalid_numbers = []

    phones_file.gsub!(/(delete|insert|update|drop|truncate|table|database|select|'|"|\^|~|`|&|\*|rm|from)/i, '')

    i = 0
    phones_file.each_line do |line|
      i = i + 1
      number = parse_phone_number(line, i)
      valid_phones << number if number
    end

    phones_in_file = valid_phones.clone
    valid_phones.uniq!
    if phones_in_file.size > valid_phones.size
      flash[:notice] = "#{flash[:notice]}<br> ** 有#{phones_in_file.size - valid_phones.size}行号码在文件重复出现（#{phones_in_file.size <= 3000 ? "比如#{phones_in_file.detect { |number| phones_in_file.count(number) > 1 }.inspect}" : '由于号码行数较多，系统就不给出重复号码示例了'}），系统已自动去掉这些重复行。"
    end

    valid_phones
  end

  def phones_from_number_server
    phones = []

    conn = Faraday.new(url: number_server_url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    res = conn.get do |req|
      req.url('/numbers', tenant_id: @bundle.company_id,
                          city: task_params[:name],
                          carrier: params[:mobile_operator])
      req.options.timeout = 60
      req.options.open_timeout = 3
    end

    res_body = JSON.parse(res.body)

    phones = res_body['numberList'] if res_body['resultCode'] == '200'

    phones
  end

  def phones_from_segment
    phones = []

    conn = Faraday.new(url: number_server_url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    res = conn.get do |req|
      req.url('/phones/from_segment', tenant_id: @bundle.company_id,
                                      start_phone: params[:start_phone].to_i,
                                      count: params[:phone_count].to_i)
      req.options.timeout = 20
      req.options.open_timeout = 3
    end

    logger.info("res.body is : #{res.body}")

    res_body = JSON.parse(res.body)

    phones = res_body['numberList'] if res_body['resultCode'] == '200'

    phones
  end

  def end_number(start_phone, phone_count)
    [start_phone.to_i + phone_count - 1, (start_phone[0..6] + '9999').to_i].min
  end

  def import_automatically?
    params[:import_method].to_i == 1
  end

  def import_by_number_segment?
    params[:import_method].to_i == 3
  end

  def valid_phones
    if import_automatically?
      return phones_from_number_server
    elsif import_by_number_segment?
      return phones_from_segment
    else
      return phones_from_upload
    end
  end

  def batch_insert_phones(numbers)
    sql_prefix = 'INSERT INTO task_phones(task_id, phone) VALUES'
    sql_arr = []

    unless numbers.blank?
      numbers.each do |number|
        sql_arr << "(#{@task.id},'#{number}')"
      end

      begin
        sql_arr.each_slice(500) do |sql_elements|
          ActiveRecord::Base.connection.execute(sql_prefix + sql_elements.join(','))
        end
      rescue Exception => e
        logger.info "Task#save_task_phones failed. @task_id= #{@task.id}. Exception is #{e.message}"
      end
    end
  end

  def save_phones_and_redirect
    phone_count_before_import = @task.task_phones.count

    save_task_phones

    @task.phone_count = ActiveRecord::Base.connection.execute("select count(1) as phone_count from task_phones where task_id=#{@task.id}").to_a.first['phone_count'].to_i
    @task.state = Task::STATE_READY if import_automatically? or import_by_number_segment? # 如果是从号码服务器自动取号，则一个号码库只允许取一次，不允许再往这个号码库导号了
    @task.save

    invalid_numbers_notice
    flash[:notice] = "#{flash[:notice]}<br>#{t('task.import_numbers_finished', w: @task.phone_count - phone_count_before_import)}" unless flash[:error]
    redirect_to kind_to_path_hash[@bundle.kind]
  end

  def task_phones_content
    @task.task_phones.pluck(:phone).join("\n")
  end
end
