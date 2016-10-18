class CustomerUploader < CarrierWave::Uploader::Base
  storage :file

  before :cache, :valid_size?

  def valid_size?(file)
    raise CarrierWave::IntegrityError, I18n.translate('customer.file_too_big') if file.size > 1200000
  end

  def extension_white_list
    %w(csv)
  end
end
