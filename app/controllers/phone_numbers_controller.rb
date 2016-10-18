class PhoneNumbersController < BaseController
  before_filter :check_logged, only: [:verify]
  skip_before_filter :check_session, only: [:verify]

  def index
    @phone_numbers = current_company.phone_numbers.order(expire_at: :desc)
  end

  def verify
    conn = Faraday.new(url: nbms_url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    begin
      res = conn.post do |req|
        req.url '/api/verify_submit'
        req.headers['Content-Type'] = 'application/json'
        req.body = { number: params[:number] }.to_json
        req.options.timeout = 6
        req.options.open_timeout = 3
      end

      res_body = JSON.parse(res.body)

      message = ''
      message = "请保持手机#{params[:number]}开机，并接听系统发起的呼叫。接通后按照语音提示，完成号码延期验证。过一分钟后刷新本页面可以看到延期是否成功。如果需要重新验证，请过一分钟后再发起，不要连续点击“申请延期”按钮。谢谢。" if res_body['code'] == 200

      render json: { message: "#{res_body['message']} #{message}" }
    rescue Exception => exception
      render json: { message: exception.message }
    end
  end
end
