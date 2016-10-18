class Admin::NumbersController < Admin::BaseController
  include Search

  before_action :set_number, only: [:edit, :update, :destroy]

  def index
    @numbers = Number.all
    @numbers = equal_search(@numbers, [:company_id])
    @numbers = like_search(@numbers, [:number])
    @numbers = @numbers.includes(:company).page(params[:page]).order(id: :desc)
  end

  def new
    @number = Number.new
  end

  def edit
  end

  def create
    @number = Number.new(number_params)

    begin
      @number.create_with_inbound_configs!(params[:inbound_max_lines])

      redirect_to admin_numbers_path, notice: t('number.created')
    rescue Exception => exception
      flash[:error] =  exception.to_s
      render :new
    end
  end

  def update
    original_number = @number.attributes

    if @number.update(number_params)
      if @number.inbound_config.nil?
        inbound_config = InboundConfig.create!({
                           company_id: @number.company_id,
                           inbound_number_id: @number.id,
                           max_inbound: params[:inbound_max_lines],
                           config_type: InboundConfig::CONFIG_TYPE_NOT_SET })

        RedisHelp.add_inbound_number(inbound_config)
      else
        if @number.company_id.nil? and original_number['company_id'].present?
          @number.inbound_config.try(:destroy)

          RedisHelp.del_inbound_number(@number.number)
        else
          @number.inbound_config.update_attribute(:max_inbound, params[:inbound_max_lines])

          RedisHelp.set_inbound_number_max_lines(@number.number, params[:inbound_max_lines])
        end
      end

      redirect_to admin_numbers_path, notice: t('number.updated')
    else
      render :edit
    end
  end

  # def destroy
  #   @number.destroy
  #
  #   redirect_to admin_numbers_path, notice: t('number.deleted')
  # end

  private

  def set_number
    @number = Number.find(params[:id])
  end

  def number_params
    params.require(:number).permit(:number, :company_id)
  end
end
