class DateTime
  def self.from_hash_with_hour(hash)
    civil_from_format(:local, hash[:year].to_i, hash[:month].to_i, hash[:day].to_i, hash[:hour].to_i, 0)
  end

  def self.from_hash_with_day(hash)
    civil_from_format(:local, hash[:year].to_i, hash[:month].to_i, hash[:day].to_i, 0, 0)
  end

  def self.transfer_string_to_date(date_string)
    unless date_string.to_s.blank? || date_string.to_s.size < 8
      date_string.gsub!(/(年|月|\/)/, '-')
      date_string.gsub!(/日/, ' ')
      if date_string.include?('-')
        value = date_string.split(' ')[0] # 只保留第一个空格前的内容。
      else
        if date_string.size == 8
          value = date_string[0..3] + '-' + date_string[4..5] + '-' + date_string[6..7]
        end
      end
      date = value.split('-')
      begin
        if (date[0].to_i > 1400 && date[0].to_i < 2250)  && (date[1].to_i > 0 && date[1].to_i <= 12) && (date[2].to_i > 0 && date[2].to_i <= 31)
          civil_from_format(:local, date[0].to_i, date[1].to_i, date[2].to_i, 0, 0)
        end
      rescue Exception => exception
        # puts exception.inspect
      end
    end
  end

  def self.left_days_this_month
    Time.days_in_month(Date.today.month, Date.today.year) - Date.today.day
  end

  def self.days_include_today_remain_current_month
    left_days_this_month + 1
  end

  def self.left_days_this_month_ratio
    (self.left_days_this_month.to_f / Time.days_in_month(Date.today.month, Date.today.year))
  end

  def self.days_include_today_remain_current_month_ratio
    (self.days_include_today_remain_current_month.to_f / Time.days_in_month(Date.today.month, Date.today.year))
  end

  def self.seconds_to_words(seconds)
    seconds = seconds.to_i
    if seconds >= 3600
      return "#{seconds / 3600}#{I18n.t(:hour)}#{(seconds % 3600) / 60}#{I18n.t(:minute)}#{seconds % 60}#{I18n.t(:second)}"
    elsif seconds >= 60
      return "#{(seconds % 3600) / 60}#{I18n.t(:minute)}#{seconds % 60}#{I18n.t(:second)}"
    else
      return "#{seconds}#{I18n.t(:second)}"
    end
  end

  def self.seconds_to_words_global(seconds)
    seconds = seconds.to_i
    if seconds >= 3600
      return "#{seconds / 3600}:#{((seconds % 3600) / 60).to_s.with_zero_prefix}:#{(seconds % 60).to_s.with_zero_prefix}"
    elsif seconds >= 60
      return "0:#{((seconds % 3600) / 60).to_s.with_zero_prefix}:#{(seconds % 60).to_s.with_zero_prefix}"
    else
      return "0:00:#{(seconds).to_s.with_zero_prefix}"
    end
  end
end