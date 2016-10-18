module PhoneNumbersHelper
  def number_expired_or_not(number)
    if number.expired?
      content_tag(:span, t(:expired), class: 'text-danger')
    else
      content_tag(:span, t(:not_expired), class: 'text-success')
    end
  end

  def remain_period(expire_at)
    content_tag(:span, expire_at > Time.now ? DateTime.seconds_to_words(expire_at.to_i - Time.now.to_i) : t(:expired), class: 'text-danger')
  end

  def phone_numbers_checkbox_for_bundle
    result = ''
    current_company.phone_numbers.task_numbers.each do |phone_number|
      result = result +
          "<input id='number_#{phone_number.number}' name='numbers[]' type='checkbox' value='#{phone_number.number}' #{phone_number_checked_or_not(phone_number.number)} />" +
          "<label for='number_#{phone_number.number}' title='#{phone_number.expire_at.strftime(t(:time_format))}过期' data-rel='tooltip' data-html='true'>&nbsp;#{phone_number.number}</label>#{link_to(number_expired_or_not(phone_number), caller_numbers_path, title: t('phone_number.enter_manage_page'), 'data-rel' => 'tooltip', style: 'text-decoration:underline;')}&nbsp;&nbsp;&nbsp;"
    end
    raw(result)
  end

  def phone_numbers_checkbox_for_salesman
    result = ''
    current_company.phone_numbers.agent_numbers.order(:number).each do |phone_number|
      result += "<input id='number_#{phone_number.number}' name='numbers[]' type='checkbox' value='#{phone_number.number}' #{sales_number_checked_or_not(phone_number.number)} />" +
                "<label for='number_#{phone_number.number}'>&nbsp;#{phone_number.number}</label>&nbsp;&nbsp;&nbsp;"
    end
    raw(result)
  end

  private

  def phone_number_checked_or_not(number)
    (@bundle.number.split(',').include?(number) ? 'checked' : '') if @bundle.number.present?
  end

  def sales_number_checked_or_not(number)
    @salesman.sales_numbers.map(&:show_number).include?(number) ? 'checked' : ''
  end
end
