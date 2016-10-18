Rails.application.routes.draw do
  get '/404' => 'errors#not_found'
  get '/500' => 'errors#internal_server_error'
  get 'errors/not_found'
  get 'errors/internal_server_error'

  mount Nbms::API => '/api/nbms'
  mount RuCaptcha::Engine => "/rucaptcha"

  resources :satisfaction_statistics

  root 'home#index'
  get 'news' => 'news#index'

  resources :issues

  resources :issue_items, only: [:create]

  get 'caller_numbers' =>'phone_numbers#index'
  post 'verify_phone_number' =>'phone_numbers#verify'

  post 'exchange_level' =>'strategies#exchange_level'
  get 'del_strategy_group' =>'strategies#del_strategy_group'
  resources :strategies

  resources :vips

  post  'satisfaction/:id' => 'satisfaction#update', as: :update_satisfaction
  resources :satisfaction, except: [:show, :destroy, :update]

  get 'exchange' => 'exchange#index'
  get 'exchange/new' => 'exchange#new'
  post  'exchange' => 'exchange#create'
  delete  'exchange/:id' => 'exchange#destroy', as: :del_exchange

  get 'color_ring' => 'color_ring#index'
  get 'color_ring/new' => 'color_ring#new'
  post  'color_ring' => 'color_ring#create'
  delete  'color_ring/:id' => 'color_ring#destroy', as: :del_color_ring

  resources :extension_configs, except: :show
  resources :inbound_configs, except: :show

  get 'nodeflow/:id' => 'nodes#index', as: :nodeflow
  resources :nodes, except: [:index, :show]

  post 'ivr_json_data' =>'ivrs#get_json'
  resources :ivrs

  get 'up_agent_inbound_level/:agent_id/:group_id' => 'groups#up_agent_inbound_level'
  get 'down_agent_inbound_level/:agent_id/:group_id' => 'groups#down_agent_inbound_level'

  get  'cdrs' => 'cdrs#search'
  get  'cdrs/filter/:date/:agent_id/:salesman_id/:call_type' => 'cdrs#filter'
  get  'history_cdrs/filter/:date/:agent_id/:salesman_id/:call_type' => 'history_cdrs#filter'

  get  'history_cdrs' => 'history_cdrs#search'

  get  'invalid_cdrs' => 'invalid_cdrs#search'

  get 'report_agent_dailies' => 'report_agent_dailies#index'
  get 'report_agent_dailies_sum' => 'report_agent_dailies#dailies_sum'
  get 'report_agent_monthlies' => 'report_agent_dailies#monthlies'
  get 'report_agent_days' => 'report_agent_dailies#days'
  get 'report_agent_today' => 'report_agent_dailies#today'
  post 'report_agent_today/publish_message' => 'report_agent_dailies#publish_message'

  get   'customers' => 'customers#index'
  get   'customers/search' => 'customers#search'
  delete 'customers/:id' => 'customers#destroy'
  get   'import_customers' => 'customers#import'
  post  'customers/do_import' => 'customers#do_import'
  get   'customers/batch_delete_by_id_range' => 'customers#batch_delete_by_id_range'
  post  'customers/do_batch_delete_by_id_range' => 'customers#do_batch_delete_by_id_range'
  get   'customers/assign_to_salesman' => 'customers#assign_to_salesman'
  post  'customers/do_assign_to_salesman' => 'customers#do_assign_to_salesman'
  get   'download_export_customers_template' => 'customers#download_export_customers_template'
  get   'buyers/:id/edit' => 'customers#edit'
  get   'customers/new' => 'customers#new'
  post  'customers' => 'customers#create'
  patch 'customers/:id' => 'customers#update'
  post  'set_vip_level/:customer_id' => 'customers#set_vip_level'
  get   'contacts' => 'contacts#index'
  post  'user_create_contact' => 'contacts#create_contact'

  get   'cdr/customer_cdrs' => 'agent/cdrs#customer_cdrs' # This is used for both user and salesman
  get   'cdr/download_record/:cdr_id' => 'agent/cdrs#download_record' # This is used for both user and salesman
  get   'cdr/downloadRecord/:accessToken/:id' => 'agent/cdrs#download_record_api' # This is used for both user and salesman
  post  'cdr/check_full_record_exist' => 'agent/cdrs#check_full_record_exist' # This is used for both user and salesman
  post  'cdr/check_original_record_exist' => 'agent/cdrs#check_original_record_exist' # This is used for both user and salesman

  get  'test_numbers' => 'customers#test_numbers'
  post 'do_test_numbers' => 'customers#do_test_numbers'

  get 'nbms/query_uc_workers' => 'nbms#query_uc_workers'
  get 'nbms/query_need_evaluate_issues_count' => 'nbms#query_need_evaluate_issues_count'

  post 'record_mixin/mixin_record' => 'record_mixin#mixin_record'

  get 'box' => 'box#index'
  get 'popup_issue/:id' => 'issues#popup'

  # For Salesman begin ====================================================
  get  'cdr' => 'agent/cdrs#search'
  get  'history_cdr' => 'agent/history_cdrs#search'
  get  'cdr/filter/:date/:agent_id/:call_type' => 'agent/cdrs#filter'
  get  'cdr/salesman_today' => 'agent/cdrs#salesman_today'

  get 'report_agent_daily' => 'agent/report_agent_dailies#index'
  get 'report_agent_day' => 'agent/report_agent_dailies#days'
  get 'report_agent_monthly' => 'agent/report_agent_dailies#monthlies'

  get   'customer' => 'agent/customers#index'
  get   'customer/new' => 'agent/customers#new'
  post  'customer' => 'agent/customers#create'
  get   'buyer/:id/edit' => 'agent/customers#edit'
  patch 'customer/:id' => 'agent/customers#update'
  get   'customer/search' => 'agent/customers#search'
  post  'call_phone/:customer_id' => 'agent/customers#call_phone'

  get   'console' => 'agent/console#index'
  get   'popup_customer/:phone/:callType' => 'agent/customers#popup'
  post  'create_contact' => 'agent/contacts#create_contact'

  get   'contact' => 'agent/contacts#index'
  get   'change_password' => 'agent/salesmen#change_password'
  patch 'update_password' => 'agent/salesmen#update_password'
  patch 'agent_update_show_number' => 'agent/agents#update_show_number'
  # For Salesman end ======================================================

  resources :users do
    member do
      get :menus
      patch :update_menus

      get :change_password
      patch :update_password
    end
  end

  resources :groups

  get 'agents/batch_config' => 'agents#batch_config'
  patch 'agents/do_batch_config' => 'agents#do_batch_config'
  resources :agents do
    member do
      post 'disable_eom' => 'agents#disable_eom'
    end
  end
  get 'agents_monitor' => 'agents_monitor#index'
  get 'monitor-agent-:agent_code' => 'agents_monitor#single_agent'
  get 'logo-name' => 'company_configs#edit'
  resources :company_configs, only: [:update]

  resources :teams

  resources :salesmen do
    member do
      get :change_password
      patch :update_password
    end
  end

  resources :valid_ips

  resources :bundles do
    member do
      post  :stash
    end

    resources :tasks do
      member do
        get   :import_numbers
        post  :do_import_numbers
        get   :export_numbers
        get   :phones
        post  :start
        post  :pause
        post  :stash
        post  :resume
      end
    end
  end

  get 'download-records-packages' => 'record_packages#index'
  resources :record_packages, only: [:index, :edit, :update]

  get 'record_formats/add_:name' => 'record_formats#add'
  get 'record_formats/remove_:name' => 'record_formats#remove'
  resources :record_formats

  ['automatic_calls', 'predict_calls', 'ivr_calls'].each do |bundle|
    get bundle => 'bundles#index'
    get "#{bundle}/history" => 'tasks#history'
  end

  resources :columns do
    member do
      patch :up
      # patch :down
    end
  end

  get 'preview' => 'columns#preview'

  resources :options

  get 'column/:type_id/options' => 'options#index'
  get 'column/:type_id/options/new' => 'options#new'
  get 'column/:type_id/options/:id/edit' => 'options#edit'
  get 'column/:type_id/options/:id/up' => 'options#up'

  resources :bills, only: [:index]

  resources :recharges, only: [:index]

  namespace :admin do
    resources :voices

    resources :server_ips

    get 'batch_config_vos' => 'companies#batch_config_vos'
    post 'do_batch_config_vos' => 'companies#do_batch_config_vos'

    resources :administrators do
      member do
        get     :points
        patch   :update_points

        get :change_password
        patch :update_password
      end
    end

    resources :companies do
      member do
        get     :assign_administrators
        patch   :do_assign_administrators
        get     :vos_config
        patch   :update_vos_config
        get     :menus
        patch   :update_menus
        get     'charge_company' => 'charge_company#edit'
        post    'charge_company/create_or_update' => 'charge_company#create_or_update'
        get     'task_config' => 'task_config#edit'
        post    'task_config/create_or_update' => 'task_config#create_or_update'
        get     'company_config' => 'company_configs#edit'
        post    'company_config/create_or_update' => 'company_configs#create_or_update'
        get     :batch_new_agents
        post    :batch_create_agents
        get     :batch_charge_agents
        post    :do_batch_charge_agents
        get     :batch_charge_change
        post    :do_batch_charge_change
        get     :batch_disable_eom
        post    :do_batch_disable_eom
        get     :recharge
        patch   :update_balance
        get     :login_as_company_admin
        patch   :apply_for_vacuum
        patch   :refuse_for_vacuum_application
        patch   :verify_for_vacuum_application
        patch   :start_vacuum
      end

      resources :agents
    end

    get 'login_as_company_salesman_:salesman_id' => 'companies#login_as_company_salesman'

    resources :agents do
      member do
        get 'edit_charge_agent' => 'charge_agent#edit'
        patch 'charge_agent/update' => 'charge_agent#update'
        patch 'charge_agent/update_monthly_rent' => 'charge_agent#update_monthly_rent'
        post 'disable_eom' => 'agents#disable_eom'
        patch 'enable' => 'agents#enable'
      end
    end

    resources :disabled_agents, only: [:index, :destroy]
    get 'disable_eom_agents' => 'agents#disable_eom_agents'

    resources :numbers

    resources :users do
      # TODO: 因为目前只有这修改密码，如何把其他的几个暂时用不到的自动生成的index, show等等都去掉？
      member do
        get :change_password
        patch :update_password
      end
    end

    get   'switch_agents_options' => 'agents#switch_agents_options'

    root 'home#index'
    get 'login' => 'login#show'
    post 'login/login' => 'login#login'
    get 'logout' => 'login#logout'

    get 'change_password' => 'administrators#change_self_password'
    patch 'update_password' => 'administrators#update_self_password'

    resources :charge_agent_minutely, :charge_agent_exceed_free, :charge_agent_monthly, :charge_agent_share_minfee
    resources :charge_company_outbound, :charge_company400, :charge_company400_months
    resources :charge_changes

    resources :phone_numbers, only: [:index]

    get 'sync_all_numbers' => 'phone_numbers#sync_all_numbers'
    get 'sync_single_company_numbers/:company_id' => 'phone_numbers#sync_single_company_numbers'
    get 'create_old_company_nbms_data' => 'companies#create_old_company_nbms_data'
  end

  get 'login' => 'login#show'
  post 'login/login' => 'login#login'
  get 'logout' => 'login#logout'

  get 'a' => 'user/login#show'
  namespace :user do
    post 'login' => 'login#login'
    get 'logout' => 'login#logout'

    get 'first_login' => 'login#first_login'
    patch 'first_login_update' => 'login#first_login_update'

    get 'change_password' => 'users#change_password'
    patch 'update_password' => 'users#update_password'
  end

  get 'pure' => 'login#pure'

  # Examples:
  #   1) http://localhost:9292/publish_faye/505/3/601091005/13812700842/0 # Manual call
  #   2) http://localhost:9292/publish_faye/503/3/601091005/13812700842/1 # Task call
  #   3) http://localhost:9292/publish_faye/503/2/601091005/13812700842/1 # Inbound call
  get 'publish_faye/:message_id/:call_type/:this_dn/:other_dn/:attach_datas' => 'login#publish'

  get 'under_construction_:index' => 'home#under_construction'
end