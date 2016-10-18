module TasksHelper
  def task_state(state)
    case state
    when Task::STATE_READY
      content_tag(:span, '未启动', class: 'text-success')
    when Task::STATE_INIT
      content_tag(:span, '导号成功', class: 'text-success', title: '导号已成功，您还可以继续导号，导入次数不限', 'data-rel' => 'tooltip')
    when Task::STATE_RUNNING
      content_tag(:span, '正在执行', class: 'text-primary')
    when Task::STATE_PAUSED
      content_tag(:span, '已暂停', class: 'text-warning')
    when Task::STATE_FINISHED
      content_tag(:span, '已完成', class: 'text-muted')
    end
  end

  def export_task_phones_button(task)
    if policy(task).export?
      content_tag(:a, raw("#{icon('save')} "), { href: export_numbers_bundle_task_path(task.bundle, task), class: 'dark' }.merge(tip('task.export_left_numbers')))
    end
  end

  def task_name_content(task)
    content_tag(:span, task.name[0..8], class: 'text-primary', 'data-content' => task_tip_content(task), 'data-rel' => 'popover', 'data-trigger' => 'hover', 'data-placement' => 'top', 'data-html' => 'true')
  end

  private

  def task_tip_content(task)
    "#{task.name.size > 7 ? "#{task.name}<br>" : ''}#{task.started_at.nil? ? '尚未启动过' : "最近启动时间：#{task.started_at.strftime(t('time_format'))}"}<br>#{"#{task.started_at.present? ? '初次启动时间' : '创建时间'}：#{task.created_at.strftime(t('time_format'))}"}<br>创建者：#{task.creator.try(:name)}#{task.remark.present? ? "<br>#{t('task.remark')}：#{task.remark}" : nil}"
  end
end
