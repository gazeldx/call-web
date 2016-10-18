class ColumnsController < BaseController
  before_action :set_column, only: [:edit, :update, :destroy, :up]

  def index
    @columns = current_company.columns.order(:created_at)
  end

  def new
    @column = Column.new
  end

  def edit
    authorize(@column, :update?)
  end

  def create
    #TODO: auth
    @column = current_company.columns.build(column_params)

    new_type_id = Column.new_type_id(params[:type], current_company)
    if params[:type] == 's' && new_type_id > Column::MAX_STRING_COUNT
      flash[:error] = t('column.reach_max_count', type_name: t('column.string'), max_count: Column::MAX_STRING_COUNT)
    elsif params[:type] == 't' && new_type_id > Column::MAX_ENUM_COUNT
      flash[:error] = t('column.reach_max_count', type_name: t('column.enum'), max_count: Column::MAX_ENUM_COUNT)
    elsif params[:type] == 'd' && new_type_id > Column::MAX_DATE_COUNT
      flash[:error] = t('column.reach_max_count', type_name: t('column.date'), max_count: Column::MAX_DATE_COUNT)
    end

    if flash[:error]
      render :new
    else
      @column.name = "#{params[:type]}#{new_type_id}"

      if @column.save
        redirect_to columns_path, notice: t('column.created')
      else
        render :new
      end
    end
  end

  def update
    authorize @column

    if @column.update(column_params)
      redirect_to columns_path, notice: t('column.updated')
    else
      render :edit
    end
  end

  def up
    exchange_created_at

    redirect_to columns_path, notice: t(:up_success)
  end

  private

  def set_column
    @column = Column.find(params[:id])
  end

  def column_params
    params.require(:column).permit(:title, :width, :target, :active)
  end

  def exchange_created_at
    model = current_company.columns.where('created_at < ?', @column.created_at).order('created_at DESC').first

    unless model.nil?
      model_created_at = @column.created_at
      @column.update_attribute('created_at', model.created_at)

      model.update_attribute('created_at', model_created_at)
    end
  end
end
