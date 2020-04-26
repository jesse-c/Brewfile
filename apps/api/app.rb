require 'roda'
require_relative './lib/brewer/brewer'


class App < Roda
  plugin :json
  plugin :not_found
  plugin :json_parser

  @@brewer = Brewer.new

  route do |r|
    r.on "api" do
      r.get "list" do
        @@brewer.list
      end

      r.get "search", String do |query|
        queries = query.split(',')

        {}
      end
    end
  end

  not_found do
    {}
  end
end
