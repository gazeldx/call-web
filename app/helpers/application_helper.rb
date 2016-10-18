module ApplicationHelper
  # def headline(&block)
  #   raw "<h1>#{capture(&block)}</h1>"
  # end

  # change the default link renderer for will_paginate
  def will_paginate(collection_or_options = nil, options = {})
    if collection_or_options.is_a?(Hash)
      options, collection_or_options = collection_or_options, nil
    end
    unless options[:renderer]
      options = options.merge :renderer => BootstrapPagination::Ace
    end
    super *[collection_or_options, options].compact
  end

  def pagination(entries)
    entries_info = content_tag(:div,
                               content_tag(:div, page_entries_info(entries), class: 'dataTables_info'),
                               class: 'col-sm-6')
    will_page = content_tag(:div,
                            content_tag(:div, will_paginate(entries), class: 'dataTables_paginate paging_bootstrap'),
                            class: 'col-sm-6')
    content_tag(:div, raw("#{entries_info}#{will_page}"), class: entries.size < WillPaginate.per_page ? nil : 'row')
  end

  # Auto generate title information. Used for [index, new, edit, create, update] actions.
  def titled
    content_for :title do
      if action_name == 'index'
        translate_text(index_i18_text)
      elsif ['new', 'edit', 'create', 'update', 'show'].include?(action_name)
        translate_text(controller_action_i18_text)
      end
    end
  end

  def title(_title)
    content_for :title do
      translate_text(_title)
    end
  end

  def translate_text(text)
    begin
      I18n.translate(text, raise: I18n::MissingTranslationData)
    rescue I18n::MissingTranslationData
      text.gsub(%r{[^.]+\.}, '')
    end
  end

  def translate_faq(text)
    begin
      I18n.translate(text, raise: I18n::MissingTranslationData)
    rescue I18n::MissingTranslationData
      t(:faq_default_content)
    end
  end

  def banner(hash)
    content_for :banner do
      lis = ''
      hash.each_with_index do |(title, url), i|
        lis += content_tag(:li, raw("#{content_tag(:i, nil, class: 'icon-home home-icon') if i == 0} #{ url ? link_to(translate_text(title), url) : translate_text(title)}&nbsp;"), class: (i == hash.length - 1 ? 'active' : nil))
      end
      content_tag(:div, content_tag(:ul, raw(lis), class: 'breadcrumb'), class: 'breadcrumbs', id: 'breadcrumbs', role: 'alert')
    end
  end

  def bannered
    banner({ t(index_i18_text) => "/#{controller_path}", t(title_with_default(nil)) => nil })
  end

  def header(header_title = t(title_with_default))
    content_for :header do
      content_tag(:span, header_title, { 'data-content' => translate_faq("#{controller_action_i18_text}_faq_content"), title: translate_faq("#{controller_action_i18_text}_faq_title")}.merge(faq_css))
    end
  end

  def title_banner_header(title = nil)
    title(title_with_default(title))
    banner({ t(index_i18_text) => "/#{controller_path}", t(title_with_default(title)) => nil })
    header(t(title_with_default(title)))
  end

  def error_msg(mo)
    if mo.errors.any?
      full_msg = ''
      mo.errors.full_messages.each do |msg|
        full_msg = full_msg + '<li>' + msg + '</li>'
      end
      raw "<div id='error_explanation' class='alert alert-danger' role='alert'><ul>#{full_msg}</ul></div>"
    end
  end

  def notice_info
    result = ''
    if flash[:notice]
      result = content_tag(:div, raw("#{content_tag(:i, nil, class: 'icon-ok')} #{flash[:notice]}"), class: 'alert alert-success', id: 'notice', role: 'alert')
    end
    flash[:notice] = nil
    result
  end

  def error_info
    result = ''
  	if flash[:error]
      result = content_tag(:div, raw("#{content_tag(:i, nil, class: 'icon-remove')} #{flash[:error]}"), class: 'alert alert-danger', id: 'error', role: 'alert')
    end
    flash[:error] = nil
    result
  end
  
  def notice_or_error
    if flash[:notice] && flash[:error]
      raw("#{notice_info} #{error_info}")
    elsif flash[:notice]
      notice_info
    else
      error_info
    end
  end

  #This is not used yet. Can be removed
  def notice_info_inner
    content_tag(:span, raw("#{content_tag(:i, nil, class: 'icon-ok')} #{flash[:notice]}"), class: 'alert alert-success collapse', id: 'notice_inner', role: 'alert')
  end

  def new?
    action_name == 'new'
  end

  def edit?
    action_name == 'edit'
  end

  def edit_or_update?
    ['edit', 'update'].include?(action_name)
  end

  def new_or_create?
    ['new', 'create'].include?(action_name)
  end

  def form_options(options = {})
    html = { class: 'form-horizontal', role: 'form' }
    html.merge!(multipart: options[:multipart]) if options.has_key?(:multipart)
    result = { html: html }
    result.merge!(url: options[:url]) if options.has_key?(:url)
    result.merge!(method: options[:method]) if options.has_key?(:method)
    result
  end

  def input_text(name, options = {})
    text_options(options)

    text_field = content_tag(:div,
                             text_field_tag("#{singularized_controller_path}[#{name}]", instance_variable_get("@#{singularized_controller_path}".to_sym).try!(name), options) + help_text(options),
                             class: 'col-sm-9')

    raw(add_space + content_tag(:div, text_label(name, options) + text_field, class: 'form-group', id: "form_group_#{name}"))
  end

  def input_text_tag(name, options = {})
    text_options(options)

    text_field = content_tag(:div,
                             text_field_tag("#{name}", '', options) + help_text(options),
                             class: 'col-sm-9')

    raw(add_space + content_tag(:div, text_label(name, options) + text_field, class: 'form-group', id: "form_group_#{name}"))
  end

  # TODO: 这个是显示为苹果风格的On-Off，目前还没有被正式使用，有机会大家可以尝试用用
  def radios2_for_boolean(column_name, options = {})
    label = labeled(column_name, required: true)

    radio = '<input name="' + "#{singularized_controller_path}[#{column_name}]" + '" class="ace ace-switch ace-switch-4" type="checkbox">'

    content_tag(:div, label + content_tag(:div, raw(radio + content_tag(:span, '', class: 'lbl')), class: 'col-sm-9'), class: 'form-group', id: column_name)
  end

  def radios_for_boolean(column_name, options = {})
    input_radios(column_name, [true, false], options)
  end

  def input_radios(column_name, value_array, options = {})
    label = labeled(column_name, { required: true }.merge(options))

    radios = ''
    value_array.each do |value|
      radio_button = radio_button_tag("#{singularized_controller_path}[#{column_name}]", value, value == instance_variable_get("@#{singularized_controller_path}".to_sym).send(column_name), options)

      span = content_tag(:span, raw(" #{radio_text(column_name, value)}" + help_text(options)), class: 'lbl', for: "#{singularized_controller_path}_#{column_name}_#{value}")

      radios += content_tag(:div, content_tag(:label, radio_button + span))
    end

    content_tag(:div, label + content_tag(:div, raw(radios), class: 'col-sm-9'), class: 'form-group', id: column_name)
  end

  def submit_form(options = {})
    button_text = options.has_key?(:button_text) ? options[:button_text] : t(:submit)

    submit = content_tag(:button, raw("#{content_tag(:i, nil, class: 'icon-ok bigger-110')} #{button_text}"), { type: 'submit', id: 'submit_button', class: 'btn btn-info' }.merge(options)) + raw('&nbsp; &nbsp; &nbsp; &nbsp;')

    content_tag(:div, content_tag(:div, submit + back_button, class: 'col-md-offset-3 col-md-9'), class: 'clearfix form-actions')
  end

  def back_button
    content_tag(:button, raw("#{content_tag(:i, nil, class: 'icon-undo bigger-110')} #{t(:return_back)}"), class: 'btn', onclick: 'window.history.back()', type: 'button')
  end

  def back_button_small
    content_tag(:button, raw("#{content_tag(:i, nil, class: 'icon-undo bigger-110')} #{t(:return_back)}"), class: 'btn btn-sm', onclick: 'window.history.back()', type: 'button')
  end

  def labeled(i18_name, options = {})
    content_tag(:label,
                raw("#{show_required_asterisk(options)}#{translate_text(i18_name.to_s.include?('.') ? i18_name : "#{singularized_controller_path}.#{i18_name}")}"),
                { class: "col-sm-3 control-label no-padding-right #{faq_hash(options).present? ? 'green' : nil}",
                  for: "#{controller_path.singularize}_#{i18_name}"
                }.merge(faq_hash(options)))
  end

  def orderIcon(column)
    if params[:orderBy] == "#{column}_desc"
      return icon('long-arrow-down')
    elsif params[:orderBy] == "#{column}_asc"
      return icon('long-arrow-up')
    end
  end

  def css_table
    { class: 'table table-striped table-bordered table-hover'}
  end

  def css_new
    { class: 'hidden_when_submit btn btn-sm btn-success pull-right' }
  end

  def css_ops
    { class: 'action-buttons' }
  end

  def tip(title)
    { 'data-original-title' => translate_text(title), 'data-rel' => 'tooltip', rel: 'nofollow' }
  end

  def faq_header(header_title = nil, options = {})
    header_title = t("#{singularized_controller_path}.management") if header_title.nil?
    options[:title] = translate_faq("#{singularized_controller_path}.faq_title") if options[:title].nil?
    options['data-content'] = translate_faq("#{singularized_controller_path}.faq_content") if options['data-content'].nil?
    options['data-placement'] = 'bottom' if options['data-placement'].nil?
    content_tag(:span, header_title, faq_css.merge(options))
  end

  def label_faq_css
    { 'data-trigger' => 'hover', 'data-rel' => 'popover', 'data-html' => 'true' }
  end

  def faq_css
    { 'data-trigger' => 'hover', 'data-rel' => 'popover', 'data-html' => 'true' }
  end

  def icon(icon_name, options = {})
    content_tag(:i, nil, { class: "icon-#{icon_name} bigger-130 #{options[:class]}" }.merge(options.except!(:class)))
  end

  def small_icon(icon_name)
    content_tag(:i, nil, class: "icon-#{icon_name}")
  end

  def odd_even(number)
    { class: (number + 1) % 2 == 0 ? 'odd' : 'even' }
  end

  def boolean_value(model, column_name)
    model.send(column_name) ? t("#{singularized_controller_path}.#{column_name}_true") : t("#{singularized_controller_path}.#{column_name}_false")
  end

  def nbsp(n = 1)
    result = ''

    n.times { result << '&nbsp;' }

    raw result
  end

  def value_more(value, n = 100)
    value = value.to_s

    if value.size > n
      content_tag(:span, "#{value[0..n - 1]}..", 'data-content' => value, 'data-trigger' => 'hover', 'data-placement' => 'top', 'data-rel' => 'popover', style: 'cursor: pointer')
    else
      content_tag(:span, value)
    end
  end

  def index_i18_text
    "#{singularized_controller_path}.management"
  end

  def title_with_default(title = nil)
    title.blank? ? controller_action_i18_text : title
  end

  def edit(url)
    raw "#{(link_to content_tag(:i, nil, class: 'icon-pencil bigger-130'), url, class: 'green', 'data-original-title' => t(:edit), 'data-rel' => 'tooltip', rel: 'nofollow')} "
  end

  # def delete(url)
  #   raw "#{(link_to content_tag(:i, nil, class: 'icon-trash bigger-130'), url, class: 'red', 'data-original-title' => t(:delete), 'data-rel' => 'tooltip', rel: 'nofollow')} "
  # end

  def stash(url = '#')
    { class: 'red', href: url, 'data-method' => 'post', data: { confirm: t(:confirm_delete) } }.merge(tip(:delete))
  end

  def search_button
    raw('&nbsp;' + content_tag(:button, raw("搜 索 #{content_tag(:i, nil, class: 'icon-search icon-on-right bigger-110')}"), type: 'submit', class: 'hidden_when_submit btn btn-purple btn-sm', id: 'search_button', onclick: "$('#target_method').val('search');"))
  end

  def export_button
    raw('&nbsp;' + content_tag(:button, raw("结果导出 #{content_tag(:i, nil, class: 'bigger-110')}"), type: 'submit', class: 'hidden_when_submit btn btn-inverse btn-sm', id: 'export_button', onclick: "$('#target_method').val('export');"))
  end

  def help_info(information)
    content_tag(:span, content_tag(:span, raw("&nbsp;&nbsp;#{information}"), class: 'middle'), class: 'help-inline')
  end

  def td_time_ago(time)
    content_tag(:td, time_ago_in_words(time), title: time.strftime(t(:time_format)), 'data-rel' => 'tooltip')
  end

  def record_full_url(file_path)
    "#{request.base_url}#{file_path}"
  end

  def hide_or_show_css(column)
    (params[column].present? ? nil : 'hidden')
  end

  def help_info(text)
    content_tag(:div, (labeled(' ') + content_tag(:div, help_tip(text), class: 'col-sm-9')), class: 'form-group')
  end

  def help_tip(text)
    content_tag(:span, content_tag(:span, raw('&nbsp;&nbsp;' + text), class: 'middle'), class: 'help-inline pink')
  end

  def play_record(record_url, id)
    content_tag(:a, icon(:music), { class: 'green', 'data-audio-url' => record_url, 'data-audio-id' => id, onclick: 'playAudio.call(this)' }.merge(tip('play_record'))) + ' '
  end

  # 录音存在与否还不知道, 如果不存在, 需要调用接口, 实时合成一下录音。合成成功后, 再显示播放条。
  def play_unknown_record(record_url, id)
    if audio_extension_file?(record_url)
      play_button_style = 'green'
      play_button_tip = t(:play_record)
    else
      play_button_style = 'blue'
      play_button_tip = '录音尚未合成，点击后将合成录音'
    end
    content_tag(:a, icon(:music), { id: 'play_button_' + id, class: play_button_style, 'data-audio-url' => record_full_url(record_url), 'data-audio-id' => id, 'data-audio-path' => record_url, onclick: 'playUnknownAudio.call(this)', 'data-content' => play_button_tip, 'data-rel' => 'popover', 'data-trigger' => 'hover', 'data-placement' => 'left' }) + ' '
  end

  def audio_player(id)
    content_tag(:div, nil, id: "player_#{id}")
  end

  def checkbox_for_search(column)
    unless action_name == 'filter'
      check_box_tag("search_#{column.to_s}", nil, params[column].present?, onclick: 'showOrHideSearchInput.call(this)')
    end
  end

  def checkbox_for_search_with_value(column, default_value)
    unless action_name == 'filter'
      check_box_tag("search_#{column.to_s}", nil, params[column].present?, onclick: "showOrHideSearchInputWithValue.call(this, '#{default_value}')")
    end
  end

  def package_records_button
    if RedisHelp.package_records_times(current_company.id) >= RecordPackage::MAX_TIMES_EVERYDAY
      content_tag(:button, t('record.package'), type: 'button', class: 'hidden_when_submit btn btn-default btn-sm', 'data-title' => "今天贵公司打包录音次数已达“#{RecordPackage::MAX_TIMES_EVERYDAY}”次上限，请明天再操作。", 'data-rel' => 'tooltip')
    else
      content_tag(:a, t('record.package'), href: "#modal-naming_and_package_records", role: 'button', class: 'hidden_when_submit btn btn-pink btn-sm', 'data-toggle' => 'modal')
    end
  end

  def batch_mixin_record_button
    if RedisHelp.batch_mixin_record_times(current_company.id) >= Company::BATCH_MIXIN_RECORD_MAX_TIMES_EVERYDAY
      content_tag(:button, t('record.batch_mixin'), type: 'button', class: 'hidden_when_submit btn btn-default btn-sm', 'data-title' => "今天贵公司批量合成录音次数已达“#{Company::BATCH_MIXIN_RECORD_MAX_TIMES_EVERYDAY}”次上限，请明天再操作。", 'data-rel' => 'tooltip')
    else
      content_tag(:button, t('record.batch_mixin'), type: 'submit', class: 'hidden_when_submit btn btn-primary btn-sm', id: 'batch_mixin_record_button', onclick: "$('#target_method').val('batch_mixin_record');")
    end
  end

  private

  def faq_hash(options = {})
    (options.keys & ['data-title', 'data-content']).any? ? label_faq_css.merge(options.slice('data-title', 'data-content')) : {}
  end

  def controller_action_i18_text
    _action_name = case action_name
                   when 'create'
                     'new'
                   when 'update'
                     'edit'
                   else
                     action_name
                   end

    "#{singularized_controller_path}.#{_action_name}"
  end

  def singularized_controller_path
    controller_path.sub('admin/', '').singularize
  end

  def show_required_asterisk(options)
    [true, ''].include?(options[:required]) ? content_tag(:span, '*', class: 'text-danger') : nil
  end

  def red_star
    content_tag(:span, '*', class: 'text-danger')
  end

  def add_space
    space = @should_add_space ? content_tag(:div, nil, class: 'space-4') : ''
    @should_add_space = true
    space
  end

  def text_options(options)
    if options.has_key?(:digits) && options[:digits]!= false
      options['data-original-title'] = t('input_digits')
      options['data-rel'] = 'tooltip'
    end

    if options.has_key?(:number) && options[:number]!= false
      options['data-original-title'] = t('input_number')
      options['data-rel'] = 'tooltip'
    end

    if options.has_key?(:range) && options[:range]!= false
      options['data-rel'] = 'tooltip'
    end

    if !options.has_key?(:class)
      if (options.has_key?(:digits) && options[:digits]!= false) ||
         (options.has_key?(:number) && options[:number]!= false) ||
         (options.has_key?(:range) && options[:range]!= false)
        options[:class] = 'col-sm-1'
      else
        options[:class] = 'col-sm-5'
      end
    end
  end

  def help_text(options)
    result = ''
    if options.has_key?(:help_text)
      result = content_tag(:span, content_tag(:span, raw('&nbsp;&nbsp;' + options[:help_text]), class: 'middle'), class: 'help-inline pink')
      options.except!(:help_text)
    end

    result
  end

  def text_label(name, options)
    content_tag(:label,
                raw("#{show_required_asterisk(options)}#{t("#{singularized_controller_path}.#{name}")}"),
                { class: "col-sm-3 control-label no-padding-right #{faq_hash(options).present? ? 'green' : nil}",
                  for: "#{controller_path.singularize}.#{name}"
                }.merge(faq_hash(options)))
  end

  def radio_text(column_name, value)
    begin
      I18n.translate("#{singularized_controller_path}.#{column_name}_#{value}", raise: I18n::MissingTranslationData)
    rescue I18n::MissingTranslationData
      return t("#{value.to_s}_") if [true, false].include?(value)
    end
  end
end
