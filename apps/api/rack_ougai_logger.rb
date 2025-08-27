# frozen_string_literal: true

require "time"
require "rubygems"
require "ougai"

module Rack
  module Ougai
    # Set up the logger
    class Logger
      def initialize(app, level = ::Logger::INFO)
        @app = app
        @level = level
      end

      def call(env)
        logger = ::Ougai::Logger.new(env[RACK_ERRORS])
        logger.level = @level

        env[RACK_LOGGER] = logger
        @app.call(env)
      end
    end

    # Log helpful info for each request
    class RequestLogger
      def initialize(app, logger = nil)
        @app = app
        @logger = logger
      end

      def call(env)
        status, headers, _body = @app.call(env)
      ensure
        logger = @logger || env[RACK_LOGGER]
        logger.info("HTTP Request", create_log(env, status, headers))
      end

      private

      def create_log(env, status, headers)
        {
          time: Time.now,
          remote_addr: env["HTTP_X_FORWARDED_FOR"] || env["REMOTE_ADDR"],
          method: env[REQUEST_METHOD],
          path: env[PATH_INFO],
          query: env[QUERY_STRING],
          status: status.to_i,
          request_id: headers["X-Request-ID"],
          timing: env["TIMING"],
        }
      end
    end
  end
end
