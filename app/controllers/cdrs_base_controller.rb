class CdrsBaseController < BaseController
  # TODO: 如果在企业级别中拿掉某个企业的'cdr.list'功能，但在浏览器输入/cdrs还是可以访问。这个权限问题也存在于其它模块
  include Cdrs, Search, SearchTeam

  def search
    search_body

    if params[:target_method] == 'export'
      authorize_and_export
    elsif params[:target_method] == 'group_report'
      @reports = @cdrs.select("DATE(start_stamp) as target_date, salesman_id, agent_id, count(1) as call_count, sum(duration) as total_duration, sum(cost) as total_cost")
                      .group(:target_date, :agent_id, :salesman_id).includes(:salesman, :agent).sort_by { |report| [report.target_date, report.call_count] }.reverse
      render :group_report
    elsif params[:target_method] == 'batch_mixin_record'
      batch_mixin_record
      redirect_to "/#{controller_name}"
    elsif params[:target_method] == 'package_records'
      package_records
      redirect_to "/#{controller_name}"
    else
      @cdrs = @cdrs.page(params[:page]) if @cdrs
      render :index
    end
  end

  # 在座席日报表页面点击通话数进行筛选
  def filter
    @cdrs = current_user.try(controller_name.to_sym)
              .where(start_stamp: DateTime.parse(params[:date])..DateTime.parse("#{params[:date]} 23:59:59"))
              .where(agent_id: params[:agent_id], salesman_id: params[:salesman_id])
              .where('duration > 0')
              .where("call_type #{params[:call_type].to_i == Cdr::CALL_TYPE_INBOUND ? '=' : '<>'} #{Cdr::CALL_TYPE_INBOUND}")
              .includes(:task, :salesman).page(params[:page])
    render :index
  end

  private

  def search_body
    if params[:start_stamp_day]
      @cdrs = current_user.try(controller_name.to_sym)

      search_start_stamp

      @cdrs = equal_search(@cdrs, [:salesman_id, :agent_id, :call_type, :callee_number, :caller_number, :task_id])

      @cdrs = search_team(@cdrs)

      search_duration

      search_call_lose

      @cdrs = @cdrs.order('start_stamp DESC').includes(:task, { salesman: :team }, :group, :agent) unless params[:target_method] == 'group_report'
    end
  end

  def batch_mixin_record
    return if @cdrs.count > max_package_records_cdrs_count

    raw_records_map = Cdr.handle_dup_record_name(Cdr.raw_records_map(@cdrs.where('duration > 0')))
    if raw_records_map.blank?
      flash[:error] = "未搜索到任何需要合成的录音。"
      return
    end

    begin
      message = { raw_records_map: raw_records_map } # raw_records_map 返回如: [["/sharedfs/record/record3031/67034/e3764efe-9419-11e5-ae0d-f171cefbc6d1", "13956011244_20151126_164421_1009"], ["/sharedfs/record/record32/60065/c90fab3c-9419-11e5-a44f-c338ecb7ad15", "15866298216_20151126_164337_1009"]]
      logger.warn "发送批量合成录音消息: #{message}"
      ::Publisher.directPublish('sneakers', 'batch_mixin_record', message)

      RedisHelp.increase_batch_mixin_record_times(current_company.id)
    rescue Exception => e
      logger.error "发送批量合成话单中的录音消息失败，原因是: #{e.message}。消息为: #{message}"
    end

    flash[:notice] = "正在为您批量合成录音，如果未合成的录音数量较多，请耐心等待。"
  end

  def package_records
    return if @cdrs.count > max_package_records_cdrs_count

    # TODO: 测试只把那些带后缀的拿去打包。
    records_map = Cdr.handle_dup_record_name(Cdr.records_map(@cdrs.where('duration > 0')))
    if records_map.blank?
      flash[:error] = "未搜索到任何可以打包的录音。"
      return
    end

    record_package = current_company.record_packages.create!(creator_id: session[:id], title: params[:title])

    begin
      message = { package_file_name: record_package.package_file_name,
                  records_map: records_map } # records_map 返回如: [["/sharedfs/record/record3031/67034/e3764efe-9419-11e5-ae0d-f171cefbc6d1.mp3", "13956011244_20151126_164421_1009"], ["/sharedfs/record/record32/60065/c90fab3c-9419-11e5-a44f-c338ecb7ad15.mp3", "15866298216_20151126_164337_1009"]]
      logger.warn "发送打包话单录音消息: #{message}"
      ::Publisher.directPublish('sneakers', 'package_records', message)

      RedisHelp.increase_package_records_times(current_company.id)
    rescue Exception => e
      logger.error "发送打包话单录音消息失败，原因是: #{e.message}。消息为: #{message}"
    end

    flash[:notice] = "正在为您打包录音，如果录音数量较多，请稍等片刻再下载。点此 ==> “<a href='#{download_records_packages_path}'>#{t('record_package.download')}</a>”。"
  end

  def authorize_and_export
    authorize(:cdr2, :export?)

    max_count = Company::BANK_UNION_DATA_IDS.include?(current_company.id) && SystemConfig.free_time? ? 500000 : 40000
    if !SystemConfig.free_time? && !Company::BANK_UNION_DATA_IDS.include?(current_company.id) && @cdrs.count > Cdr::MAX_EXPORT_COUNT_ON_BUSY_TIME # 这里是双重保护了下, 页面上已经做了控制了。
      send_data(t(:operate_at_free_time).encode('gbk', 'utf-8'), filename: "由于导出的话单数量超过#{Cdr::MAX_EXPORT_COUNT_ON_BUSY_TIME}条，数量比较大，#{t(:operate_at_free_time)}.csv")
    elsif @cdrs.count > max_count
      send_data(t('cdr.export_max_content', w: max_count).encode('gbk', 'utf-8'), filename: "#{t('cdr.export_max_title', w: max_count)}.csv")
    else
      export_cdrs
    end
  end

  def export_cdrs
    logger.warn("====== #{Time.now.strftime(t("time_without_year"))} start export ============")
    content = cdrs_content.encode('gbk', 'utf-8')
    logger.warn("====== #{Time.now.strftime(t("time_without_year"))} end   export ============")
    send_data(content, filename: "Cdrs.csv")
    logger.warn("====== #{Time.now.strftime(t("time_without_year"))} finish export ============")
  end

  def cdrs_content
    csv_array = []
    # TODO: BUG - 话费作为一个权限存在, 应该被用在对此处导出的控制中来。
    # TODO: 如果把record_url导出, 注意obtain_records_limit_ip为true时,最好别让他们导出了。因为对他们而言, 不安全。
    csv_array << ([t(:callee_number), t(:caller_number), t(:time_), t('cdr.call_type'), "#{t('cdr.duration')}（#{t(:second)}）", "#{t('cdr.fee')}（#{t(:yuan)}）", t(:agent_), t(:salesman_), t(:call_loss_or_not)] + (Company::BANK_UNION_DATA_IDS.include?(current_company.id) ? [t('cdr.record_url')] : [])).join(',')
    can_view_phone_number = policy(:user2).view_phone_number?
    @cdrs.each { |cdr| csv_array << a_cdr_line(cdr, can_view_phone_number) }
    csv_array.join("\n")
  end

  def a_cdr_line(cdr, can_view_phone_number)
    line = [
      can_view_phone_number ? cdr.callee_number : hide_middle_digits(cdr.callee_number), # 考虑性能, 所以没有用refined_phone()
      can_view_phone_number ? cdr.caller_number : hide_middle_digits(cdr.caller_number),
      cdr.answer_stamp.present? ? cdr.answer_stamp.strftime(t(:time_format_simple)) : cdr.start_stamp.strftime(t(:time_format_simple)),
      t("cdr.call_type_#{cdr.call_type}"),
      "#{cdr.duration}",
      "#{cdr.cost.to_f}",
      cdr.agent_id.nil? ? '' : cdr.agent_id.to_s.slice(5, 9),
      cdr.salesman.try(:name),
      cdr.call_loss? ? "#{t(:call_loss)}-#{cdr.group_id.to_i > 0 ? t('cdr.group_transferred', w: cdr.group.name) : t('cdr.not_transfer_to_group')}" : t(:not_call_loss)
    ]
    line << cdr.record_url if Company::BANK_UNION_DATA_IDS.include?(current_company.id)
    line.join(',')
  end
end
