# frozen_string_literal: true

require 'roda'
require 'securerandom'
require_relative './lib/brewer/brewer'

# An API for working with Brewfile templates
class App < Roda
  plugin :not_found
  plugin :halt
  plugin :hooks
  plugin :type_routing, default_type: :txt, types: {
                          txt: "text/plain",
                        }

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
      r.get 'list' do
        results = brewer.list
        r.json { brewer.present(results, "json") }
        r.txt { brewer.present(results) }
      end

      r.on 'search' do
        r.get String do |query|
          queries = query.split(',')

          if queries.empty?
            response.status = 400
            r.json { '{"errors":["Need ≥ 1 Brewfile names"]}' }
            r.txt { "Need ≥ 1 Brewfile names" }
          end

          results = brewer.search(queries)
          r.json { brewer.present(results, "json") }
          r.txt { brewer.present(results) }
        end

        r.get do
          response.status = 400
          r.json { '{"errors":["Need ≥ 1 Brewfile names"]}' }
          r.txt { "Need ≥ 1 Brewfile names" }
        end
      end

      r.on 'generate' do
        r.get String do |query|
          queries = query.split(',')

          if queries.empty?
            response.status = 400
            r.json { '{"errors":["Need ≥ 1 Brewfile names"]}' }
            r.txt { "Need ≥ 1 Brewfile names" }
          end

          results = brewer.generate(queries)
          r.json { brewer.present(results, "json") }
          r.txt { brewer.present(results) }
        end

        r.get do
          response.status = 400
          r.json { '{"errors":["Need ≥ 1 Brewfile names"]}' }
          r.txt { "Need ≥ 1 Brewfile names" }
        end
      end
    end
  end
end
