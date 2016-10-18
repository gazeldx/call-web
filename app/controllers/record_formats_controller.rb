class RecordFormatsController < BaseController
  def index
  end

  def add
    @record_format = current_company.record_formats.build(name: params[:name])
    if @record_format.save
      flash[:notice] = t('record_format.created')
    else
      flash[:error] = t(:fail, w: '操作')
    end
    redirect_to record_formats_path
  end

  def remove
    current_company.record_formats.find_by_name(params[:name]).try(:destroy)
    redirect_to record_formats_path, notice: t('record_format.deleted')
  end
end
