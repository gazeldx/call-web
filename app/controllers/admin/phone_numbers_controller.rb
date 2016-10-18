# 用于和“号码管理系统-nbms”交互
class Admin::PhoneNumbersController < Admin::BaseController
  include Search

  before_action :has_point_phone_number_management?

  def index
    @phone_numbers = PhoneNumber.all
    @phone_numbers = equal_search(@phone_numbers, [:company_id])
    @phone_numbers = like_search(@phone_numbers, [:number])
    @phone_numbers = @phone_numbers.includes(:company).page(params[:page]).order(id: :desc)
  end

  def sync_all_numbers
    @result = {}

    error_numbers = []
    all_numbers_count = 0
    number_success_count = 0

    conn = Faraday.new(url: nbms_url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    begin
      res = conn.get do |req|
        req.url '/api/whitelist_init', begin_tenant_id: 60000
        req.options.timeout = 30
        req.options.open_timeout = 10
      end

      res_body = JSON.parse(res.body)

      if res_body['code'] == 200
        if res_body['data']['count'] > 0
          PhoneNumber.destroy_all
          RedisHelp.del_caller_numbers

          all_numbers_count = res_body['data']['count']
          res_body['data']['numbers'].each_with_index do |number, i|
            begin
              create_caller_number(number)
              number_success_count = number_success_count + 1
            rescue Exception => exception
              error_numbers << number
              logger.error("从“号码管理系统”同步数据出错：#{exception.to_s}。错误的id为#{i}，号码数据为：#{number.inspect}")
            end
          end
        end
      else
        flash[:error] = "向“号码管理系统”调用初始化数据 /api/whitelist_init 时，返回了未知的错误: #{res_body['data']}！请联系统一通信研发人员张健或许利强。"
      end
    rescue Exception => exception
      flash[:error] = "向“号码管理系统”调用初始化数据 /api/whitelist_init 时，遇到了异常：#{exception.to_s}！请联系统一通信研发人员张健或许利强。"
    end

    @result[:error_numbers] = error_numbers
    @result[:number_success_count] = number_success_count
    @result[:all_numbers_count] = all_numbers_count
    @result
  end

  def sync_single_company_numbers
    company = Company.find(params[:company_id])

    return { message: '企业编号不存在！' } if company.blank?
    @result = {}

    error_numbers = []
    all_numbers_count = 0
    number_success_count = 0

    conn = Faraday.new(url: nbms_url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    begin
      res = conn.get do |req|
        req.url '/api/whitelist_init', tenant_id: company.id
        req.options.timeout = 30
        req.options.open_timeout = 10
      end

      res_body = JSON.parse(res.body)

      if res_body['code'] == 200
        if res_body['data']['count'] > 0 # 由于用了"> 0"这个条件, 在发生故障时, 这里可能出现nbms上已经没有主叫了, 但在页面点同步企业主叫号码却没有同步过来的情况。由于概率很小, 为保险起见, 还是用 > 0 这个条件, 保证少出错。
          company.phone_numbers.destroy_all
          RedisHelp.del_company_caller_numbers(company.id)

          all_numbers_count = res_body['data']['count']
          res_body['data']['numbers'].each_with_index do |number, i|
            begin
              create_caller_number(number)
              number_success_count = number_success_count + 1
            rescue Exception => exception
              error_numbers << number
              logger.error("从“号码管理系统”同步数据出错：#{exception.to_s}。错误的id为#{i}，号码数据为：#{number.inspect}")
            end
          end
        end
      else
        flash[:error] = "向“号码管理系统”调用初始化数据 /api/whitelist_init 时，返回了未知的错误: #{res_body['data']}！请联系统一通信研发人员张健或许利强。"
      end
    rescue Exception => exception
      flash[:error] = "向“号码管理系统”调用初始化数据 /api/whitelist_init 时，遇到了异常：#{exception.to_s}！请联系统一通信研发人员张健或许利强。"
    end

    @result[:error_numbers] = error_numbers
    @result[:number_success_count] = number_success_count
    @result[:all_numbers_count] = all_numbers_count
    @result[:company_info] = company.name_and_id
    @result
  end

  private

  def has_point_phone_number_management?
    redirect_to admin_root_path unless current_user.have_point('phone_number.management')
  end

  def number_hash(number)
    { company_id: number['tenant_id'],
      number: number['number'],
      for_task: ['tasks', 'both'].include?(number['purpose']),
      for_agent: ['agents', 'both'].include?(number['purpose']),
      expire_at: number['expire_at'],
      validity_hours: number['validity'].to_i }
  end

  def create_caller_number(number)
    PhoneNumber.create!(number_hash(number))

    RedisHelp.set_caller_number(number['tenant_id'], number['number'], number['expire_at'])
  end
end
