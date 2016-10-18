class VoiceUploader < CarrierWave::Uploader::Base
  storage :file

  before :cache, :valid_size?

  def valid_size?(file)
    raise CarrierWave::IntegrityError, I18n.translate('voice.file_too_big') if file.size > 1048576
  end

  def store_dir
    "#{Settings.nfs_base_path}/#{model.class.to_s.underscore}/#{model.company.id}"
  end

  def extension_white_list
    %w(wav)
  end

  def filename
    "#{Time.now.strftime('%Y%m%d%H%M%S')}.wav" if original_filename
  end
end
