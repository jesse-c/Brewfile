# frozen_string_literal: true

require 'roda'
require 'securerandom'
require_relative './lib/brewer/brewer'

# An API for working with Brewfile templates
class App < Roda
  plugin :not_found
  plugin :halt
  plugin :hooks

  before do
    @time = Time.now
    @request_id = SecureRandom.uuid
  end

  after do |_res|
    env['TIMING'] = Time.now - @time
    response['X-Request-ID'] = @request_id
  end

  not_found do
    ''
  end

  brewer = Brewer.new

  route do |r|
    r.get 'health' do
      response.status = 200

      ''
    end

    r.on 'api' do
      response['Content-Type'] = 'text/plain'

      r.get 'list' do
        brewer.present(brewer.list)
      end

      r.on 'search' do
        r.get String do |query|
          queries = query.split(',')

          if queries.empty?
            response.status = 400
            response['Content-Type'] = 'application/json'
            return '{"errors":["Need ≥ 1 Brewfile names"]}'
          end

          results = brewer.search(queries)

          brewer.present(results)
        end

        r.get do
          response.status = 400
          response['Content-Type'] = 'application/json'
          '{"errors":["Need ≥ 1 Brewfile names"]}'
        end
      end

      r.on 'generate' do
        r.get String do |query|
          queries = query.split(',')

          if queries.empty?
            response.status = 400
            response['Content-Type'] = 'application/json'
            return '{"errors":["Need ≥ 1 Brewfile names"]}'
          end

          results = brewer.generate(queries)

          brewer.present(results)
        end

        r.get do
          response.status = 400
          response['Content-Type'] = 'application/json'
          '{"errors":["Need ≥ 1 Brewfile names"]}'
        end
      end
    end
  end
end
