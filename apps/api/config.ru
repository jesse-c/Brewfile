require './app.rb'
require_relative 'rack_ougai_logger'

use Rack::Ougai::Logger
use Rack::Ougai::RequestLogger

run App
