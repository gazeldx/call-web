require 'machinist/active_record'
require 'ffaker'

Dir[File.join(File.dirname(__FILE__), 'blueprints', '*_blueprint.rb')].each { |blueprint| require blueprint }
