module CdrBase
  def call_loss?
    self.bridge_stamp.nil? and (self.call_type == Cdr::CALL_TYPE_TASK || (self.call_type == Cdr::CALL_TYPE_INBOUND && self.group_id.present?))
  end

  def record_filename(hide_phone_number = false)
    record_format_names = self.company.record_formats.order(:id).map(&:name)
    (record_format_names.blank? ? ['calleeNumber', 'date'] : record_format_names).map do |name|
      record_partial_name(name, hide_phone_number)
    end.join('_')
  end

  def record_partial_name(record_format_name, hide_phone_number)
    case record_format_name
      when 'calleeNumber' then (hide_phone_number ? self.callee_number.hide_middle_digits : self.callee_number)
      when 'callerNumber' then self.caller_number
      when 'duration' then self.duration
      when 'agentCode' then self.agent_id.to_s.slice(5, 9)
      when 'date' then self.start_stamp.strftime("%Y%m%d")
      when 'time' then self.start_stamp.strftime("%H%M%S")
      when 'salesmanName' then self.salesman.try(:name).to_s.gsub(/[\*\\\/\.\`\@\&\~\!\#\$\%\^\,\?\'\;\?\"]/, '') # 去除非法字符
      else ''
    end
  end

  def duration_as_words
    DateTime.seconds_to_words(self.duration)
  end

  def call_type_name
    result = I18n.t("cdr.call_type_#{self.call_type}")
    if self.call_type == Cdr::CALL_TYPE_TASK
      result = "#{result}(#{self.task.try(:name).present? ? self.task.try(:name) : I18n.t('task.is_deleted')})"
    end
    result
  end

  def start_stamp_formatted
    self.start_stamp.strftime(I18n.t(:time_format))
  end

  # def agent_extension_names
  #   if self.agent_id.present?
  #     self.agent.extension_names
  #   end
  # end
end
