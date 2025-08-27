# frozen_string_literal: true

require "./app"

require_relative "rack_ougai_logger"

use Rack::Ougai::Logger
use Rack::Ougai::RequestLogger

run App.freeze.app
