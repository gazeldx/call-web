class LogoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  before :cache, :valid_size?

  def valid_size?(file)
    raise CarrierWave::IntegrityError, I18n.translate('company_config.logo_too_big') if file.size > 2097152
  end

  def store_dir
    "#{Settings.nfs_base_path}/upload_images/#{model.company.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    "logo-#{(model.company.id * 18) + 1472}#{File.extname(super).downcase}" if original_filename
  end

  process resize_to_limit: [690, nil]

  version :small do
    process resize_to_fill: [23, 23]
  end

  version :middle do
    process :resize_to_fill => [28, 28]
  end
end
