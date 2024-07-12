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

  @@brewer = Brewer.new

  route do |r|
    r.get 'health' do
      response.status = 200
      ''
    end

    r.on 'api' do
      response['Content-Type'] = 'text/plain'

      r.get 'list' do
        @@brewer.present(@@brewer.list)
      end

      r.get 'search', String do |query|
        queries = query.split(',')

        results = @@brewer.search(queries)

        @@brewer.present(results)
      end

      r.get 'generate', String do |query|
        queries = query.split(',')

        r.halt(400, { errors: ['Need ≥ 1 Brewfile names'] }) if queries.empty?

        results = @@brewer.generate(queries)

        @@brewer.present(results)
      end

      r.get 'generate' do
        r.halt(400, { errors: ['Need ≥ 1 Brewfile names'] })
      end

      r.get 'generate/' do
        r.halt(400, { errors: ['Need ≥ 1 Brewfile names'] })
      end
    end
  end
end
