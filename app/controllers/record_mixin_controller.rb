class RecordMixinController < BaseController
  skip_before_filter :check_session, only: [:mixin_record]

  def mixin_record
    conn = Faraday.new(url: record_mixin_url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    res = conn.get do |req|
      req.url('/api/recordMixInstant', record: params[:record_file_without_extension],
                                       uuid: params[:uuid])
      req.options.timeout = 1
      req.options.open_timeout = 1
    end

    logger.warn(" ========================= recordMixInstant res.body is #{res.body.inspect}")
    render json: { result: 'success' }
  end
end
