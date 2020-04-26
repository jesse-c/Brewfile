ENV['RACK_ENV'] = 'test'

require "test/unit"
require 'rack/test'

require './app.rb'

include Rack::Test::Methods

class HomepageTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    app = App.new
    builder = Rack::Builder.new
    builder.run app
  end

  def test_response_is_ok
    get '/hello'

    assert last_response.ok?
    assert_equal last_response.body, 'hello!'
  end
end
