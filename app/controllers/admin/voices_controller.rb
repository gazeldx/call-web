class Admin::VoicesController < Admin::BaseController
  include Search

  before_action :set_voice, only: [:edit, :update, :destroy]

  def index
    @voices = Voice.all
    @voices = equal_search(@voices, [:company_id])
    @voices = @voices.includes(:company).order('created_at DESC').page(params[:page])
  end

  def new
    @voice = Voice.new
  end

  def edit
  end

  def create
    @voice = Voice.new(voice_params.merge(checker_id: session[:id]))

    upload_and_save_voice

    redirect_to admin_voices_path
  end

  def update
    begin
      @voice.update_attributes!(voice_params.merge(checker_id: session[:id]))
      RedisHelp.add_voice(@voice)
      flash[:notice] = t('voice.updated')
    rescue Exception => e
      flash[:error] = e.message
    end

    redirect_to admin_voices_path
  end

  #TODO: Destory feature.
  #Liu: We need not support delete. Only support modify is enough.

  private

  def set_voice
    @voice = Voice.find(params[:id])
  end

  def voice_params
    params.require(:voice).permit(:name, :company_id, :duration, :file)
  end


  def upload_and_save_voice
    begin
      @voice.save!
      RedisHelp.add_voice(@voice)
    rescue Exception => e
      flash[:error] = e.message
      return
    end
    flash[:notice] = t('voice.created')
  end
end
