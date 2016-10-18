class OptionsController < BaseController
  before_action :set_column, only: [:index, :new, :edit, :up]
  before_action :set_option, only: [:edit, :update, :destroy, :up]

  def index
    @options = current_company.options.where(tid: params[:type_id]).order(:created_at)
  end

  def new
    @option = Option.new(tid: params[:type_id])
  end

  def edit
    authorize(@column, :update?)
  end

  def create
    @option = current_company.options.build(option_params)

    if @option.save
      redirect_to "/column/#{option_params[:tid]}/options", notice: t('option.created')
    else
      flash[:error] = @option.errors.messages
      redirect_to "/column/#{option_params[:tid]}/options/new"
    end
  end

  def update
    if @option.update(option_params)
      redirect_to "/column/#{option_params[:tid]}/options", notice: t('option.updated')
    else
      flash[:error] = @option.errors.messages
      redirect_to "/column/#{option_params[:tid]}/options/#{@option.id}/edit"
    end
  end

  def up
    exchange_created_at(@column.options, @option)

    redirect_to "/column/#{@column.name.gsub(/[^0-9]/, '').to_i}/options", notice: t(:up_success)
  end

  private

  def set_column
    @column = current_company.columns.find_by_name("t#{params[:type_id]}")
  end

  def set_option
    @option = Option.find(params[:id])
  end

  def option_params
    params.require(:option).permit(:text, :tid)
  end
end
