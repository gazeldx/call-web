module Nbms
  class API < Grape::API
    version 'v1', using: :header, vendor: 'uc'
    format :json
    prefix '/'

    helpers do
      def current_user
        true
        # @current_user ||= User.authorize!(env)
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_user
      end

      def logger
        @@nbms_api_logger ||= Logger.new("#{Rails.root}/log/api_nbms_logger.log")
      end
    end

    # 调用示例：curl -d '{"numbers": [{"number": "13812700843", "company_id": 66002, "method": "add", "purpose": "tasks"}]}' 'http://127.0.0.1:9292/api/nbms/sync_numbers' -H Content-Type:application/json -v
    desc "当号码管理系统号码数据有变动时，通过本接口进行同步"
    post '/sync_numbers' do
      logger.info("开始调用 /sync_numbers，参数：#{params.inspect}")

      PhoneNumber.sync_numbers(params)

      logger.info("完成调用 /sync_numbers")

      { result: 'success', reason: '' }
    end
  end
end