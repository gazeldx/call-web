class PhoneUploader < CarrierWave::Uploader::Base
  storage :file

  before :cache, :valid_size?

  def valid_size?(file)
    raise CarrierWave::IntegrityError, I18n.translate('task.file_too_big') if file.size > 800000
  end

  def extension_white_list
    %w(csv txt)
  end
end
