require './app.rb'
require 'rack-request-id'
require_relative 'rack_ougai_logger'

use Rack::RequestId, id_generator: proc { SecureRandom.uuid }
use Rack::Ougai::Logger
use Rack::Ougai::RequestLogger

run App.freeze.app
