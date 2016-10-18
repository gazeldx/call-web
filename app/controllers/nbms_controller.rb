class NbmsController < BaseController
  skip_before_filter :check_session, only: [:query_uc_workers]

  def query_uc_workers
    conn = Faraday.new(url: nbms_url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    res = conn.get do |req|
      req.url('/api/get_staffs', tenant_id: current_company.id)
      req.options.timeout = 2
      req.options.open_timeout = 1
    end

    render json: JSON.parse(res.body)
  end

  def query_need_evaluate_issues_count
    conn = Faraday.new(url: nbms_url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    res = conn.post do |req|
      req.url '/api/get_need_evaluate_issues_count'
      req.headers['Content-Type'] = 'application/json'
      req.body = { tenant_id: current_company.id }.to_json
      req.options.timeout = 2
      req.options.open_timeout = 1
    end

    render json: JSON.parse(res.body)
  end
end
