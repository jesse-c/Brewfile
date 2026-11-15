# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "rbconfig"

describe "Deployment entry point" do
  it "boots and serves health requests with the logging middleware" do
    script = <<~'RUBY'
      require "rack"
      app = Rack::Builder.parse_file("config.ru")
      response = Rack::MockRequest.new(app).get("/health")
      abort "Health check failed: #{response.status}" unless response.status == 200
    RUBY

    stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-e", script)

    _(status.success?).must_equal true, "#{stdout}\n#{stderr}"
  end
end
