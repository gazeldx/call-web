# Be sure to restart your server when you modify this file.
# Rails.application.config.session_store :cookie_store, key: '_ucweb_session' # 会报错ActionDispatch::Cookies::CookieOverflow . 所以用 :active_record_store 了
Rails.application.config.session_store :active_record_store, :key => '_ucweb_session'
