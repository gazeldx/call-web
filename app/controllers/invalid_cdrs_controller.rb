class InvalidCdrsController < BaseController
  include Cdrs, Search

  def search
    authorize(:system, :free_time?)

    search_body

    if params[:target_method] == 'export'
      max_count = 50000
      if @invalid_cdrs.to_a.count > max_count
        send_data(t('cdr.export_max_content', w: max_count).encode('gbk', 'utf-8'), filename: "#{t('cdr.export_max_title', w: max_count)}.csv")
      else
        export_cdrs
      end
    else
      @invalid_cdrs = @invalid_cdrs.page(params[:page]) if @invalid_cdrs

      render :index
    end
  end

  def search_body
    if [:start_stamp_start, :task_id, :callee_number, :caller_number].any? { |key| params[key].present? }
      @invalid_cdrs = current_user.invalid_cdrs
      @invalid_cdrs = time_range_search(@invalid_cdrs, [:start_stamp])
      @invalid_cdrs = equal_search(@invalid_cdrs, [:task_id, :callee_number, :caller_number])
      @invalid_cdrs = @invalid_cdrs.order('start_stamp DESC').includes(:task)
    end
  end

  def export_cdrs
    send_data(invalid_cdrs_content.encode('gbk', 'utf-8'), filename: "Invalid_Cdrs.csv")
  end

  private

  def invalid_cdrs_content
    csv_array = []
    csv_array << [t(:line_no), t(:callee_number), t(:caller_number), t('cdr.time'), t('task.name'), t('invalid_cdr.kind')].join(',')

    @invalid_cdrs.to_a.each_with_index { |invalid_cdr, i| csv_array << a_invalid_cdr_line(invalid_cdr, i) }

    csv_array.join("\n")
  end

  def a_invalid_cdr_line(invalid_cdr, i)
    [ i + 1,
      invalid_cdr.callee_number,
      invalid_cdr.caller_number,
      invalid_cdr.start_stamp.strftime(t('time_without_year')),
      invalid_cdr.task.try(:name),
      t("invalid_cdr.kind_unknown")
    ].join(',')
  end
end
