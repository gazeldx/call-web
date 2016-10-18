class Admin::TaskConfigController < Admin::BaseController
  before_action :set_company, only: [:edit, :create_or_update]

  def edit
    @task_config = (@company.task_config.present? ? @company.task_config : TaskConfig.new)
    set_return_to
  end

  def create_or_update
    if @company.task_config.present?
      if @company.task_config.update(task_config_params)
        flash[:notice] = t('task_config.updated', w: @company.name_and_id)
        return_to
      else
        @task_config = @company.task_config
        render :edit
      end
    else
      @task_config = @company.build_task_config(task_config_params)

      if @task_config.save
        flash[:notice] = t('task_config.created', w: @company.name_and_id)
        redirect_to company_config_admin_company_path(@company)
      else
        render :edit
      end
    end
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def task_config_params
    params.require(:task_config).permit(:long_idle_time, :long_checkin, :predict_max_ratio, :voice_max_ratio, :voice_max_duration, :keypress_max_concurrency)
  end
end
