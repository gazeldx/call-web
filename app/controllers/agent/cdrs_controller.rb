class Agent::CdrsController < Agent::CdrsBaseController
  skip_before_filter :check_session, only: [:customer_cdrs, :download_record, :check_full_record_exist, :check_original_record_exist, :download_record_api]

  def customer_cdrs
    customer = Customer.find(params[:customer_id])
    # TODO: 呼入的通话记录没有查询, 需要在页面上提示需要关心呼入电话的用户. 因为caller_number中没有索引, 而且目前cdrs中的索引已经很多了, 不适合再加.
    # 当日的话单 + 历史的话单(不含当日) = 全部话单
    cdrs = customer_cdrs_json(customer, current_company.cdrs.where(start_stamp: Time.now.beginning_of_day..Time.now.end_of_day)) + customer_cdrs_json(customer, current_company.history_cdrs)
    cdrs.each { |cdr| cdr.merge!(refined_phone: refined_phone(cdr['callee_number'])) } # 本行实现了隐藏号码的需求
    render json: { cdrs: cdrs }
  end

  def download_record
    cdr = HistoryCdr.find_by_id(params[:cdr_id])
    cdr = Cdr.find(params[:cdr_id]) if cdr.nil?
    # TODO: 时常有客户发图片说报错, 其实是文件不存在。最好能够在文件不存在时, 页面上提示出不存在(如果使用File.exist?, 应该以不影响性能为前提)
    send_file(cdr.record_url,
              type: "audio/#{cdr.record_url.file_extension_type}",
              filename: cdr.record_filename(!policy(:company_config2).salesman_can_see_numbers? && current_user.is_a?(Salesman)) + ".#{cdr.record_url.file_extension_type}")
  end

  # 通过API接口下载录音
  def download_record_api
    # TODO: 下面时间段的限制要在正式上线时启用。
    # render json: { status: 403, error: { code: 30122, message: "请在早7:00前，晚21:00后查询话单。" } } unless (Time.now < Time.parse('07:00', Time.now)) || (Time.now >= Time.parse('21:00', Time.now))
    unless ["a5c19be8413ac0f0f75ed37136f74638af5ac173", "315e85882238e5243194ab5847fd838f2834e0e7"].include?(params[:accessToken])
      render json: { status: 401, error: { code: 30129, message: "您没有权限进行本次查询。", fields: ["accessToken"] } }
      return
    end
    cdr = HistoryCdr.find_by_id(params[:id])
    cdr = Cdr.find_by_id(params[:id]) if cdr.nil?
    if cdr.nil?
      render json: { status: 404, error: { code: 30130, message: "未查询到该话单。", fields: ["id"] } }
    else
      file_type = audio_extension_file?(cdr.record_url) ? cdr.record_url.file_extension_type : 'G729'
      file_name_in  = cdr.record_filename + (file_type == 'G729' ? '-in'  : '') + ".#{file_type}"
      file_name_out = cdr.record_filename + (file_type == 'G729' ? '-out' : '') + ".#{file_type}"
      send_file(file_type == 'G729' ? "#{cdr.record_url}-in.G729" : cdr.record_url,
                type: "audio/#{file_type}",
                filename: file_name_in)
      send_file(file_type == 'G729' ? "#{cdr.record_url}-out.G729" : cdr.record_url,
                type: "audio/#{file_type}",
                filename: file_name_out)
    end
  end

  # 检测带后缀(如: .mp3或.wav)的录音存在性(本方法目前没有被使用)
  def check_full_record_exist
    record_file = params[:record_url].slice(params[:record_url].index(Settings.nfs_base_path)..500)
    # TODO: 如果时间是近三个月内, 带.mp3(或.wav)后缀, 并且时间已经超过了2分钟, 就不用检查文件是否存在了, 应该都是存在的.
    render json: { result: File.exist?(record_file) ? 'record_exist': 'record_not_exist',
                   record_uuid: params[:record_uuid] }
  end

  # 检测不带后缀的录音存在性(本方法目前没有被使用)
  def check_original_record_exist
    record_file_without_extension = params[:record_url].slice(params[:record_url].index(Settings.nfs_base_path)..500)
    render json: { result: File.exist?("#{record_file_without_extension}-in.G729") && File.exist?("#{record_file_without_extension}-out.G729") ? 'original_record_exist' : 'original_record_not_exist',
                   record_uuid: params[:record_uuid],
                   record_file_without_extension: record_file_without_extension }
  end

  # def check_record_exist
  #   record_file = params[:record_url].slice(params[:record_url].index(Settings.nfs_base_path)..500)
  #   result = 'record_not_exist'
  #   result = 'record_exist' if File.exist?(record_file) # TODO: 如果时间是近三个月内, 带.mp3(或.wav)后缀, 并且时间已经超过了2分钟, 就不用检查文件是否存在了, 应该都是存在的.
  #   result = 'original_record_exist' if File.exist?(original_record_file(record_file, '-in.G729')) && File.exist?(original_record_file(record_file, '-out.G729'))
  #   render json: { result: result, record_uuid: params[:record_uuid], record_file_without_extension: original_record_file(record_file, '') }
  # end

  # 在座席日报表页面点击通话数进行筛选
  def filter
    authorize(:cdr2, :view?)

    @cdrs = current_user.history_cdrs.where(start_stamp: DateTime.parse(params[:date])..DateTime.parse("#{params[:date]} 23:59:59"))
                .where(agent_id: params[:agent_id])
                .where('duration > 0')
                .where("call_type #{params[:call_type].to_i == Cdr::CALL_TYPE_INBOUND ? '=' : '<>'} #{Cdr::CALL_TYPE_INBOUND}")
                .includes(:task).page(params[:page])

    render :index
  end

  # 销售员当日统计
  def salesman_today
    today_data = ActiveRecord::Base.connection.execute("SELECT COUNT(1) AS answered_count, SUM(duration) AS duration FROM cdrs WHERE salesman_id = #{current_user.id} AND company_id = #{current_user.company_id} AND (start_stamp >= '#{Time.now.strftime(t(:date_format_))} 00:00:00.000000' AND duration > 0)").to_a[0]

    render json: { answered_count: today_data['answered_count'].to_i,
                   duration: DateTime.seconds_to_words(today_data['duration'].to_i) }
  end

  # private
  #
  # def original_record_file(record_file, record_file_tail)
  #   record_file.slice(0..(record_file.index(".#{record_file.file_extension_type}") - 1)) + record_file_tail.to_s
  # end
end
