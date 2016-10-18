class Date
  def self.valid_month?(str, format="%Y%m")
    Date.strptime(str, format) rescue false
  end

  def wday_name
    wday_chinese = { 0 => '日', 1 => '一', 2 => '二', 3 => '三', 4 => '四', 5 => '五', 6 => '六' }
    "#{I18n.t(:week)}#{wday_chinese[self.wday]}"
  end
end