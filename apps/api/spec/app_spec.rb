# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require './app'

describe App do
  include Rack::Test::Methods

  def app
    App.freeze.app
  end

  describe 'health endpoint' do
    it 'returns 200 OK' do
      get '/health'
      _(last_response.status).must_equal 200
      _(last_response.body).must_equal ''
    end
  end

  describe 'API endpoints' do
    describe 'when listing brewfiles' do
      it 'returns a list of all brewfiles' do
        get '/api/list'
        _(last_response.status).must_equal 200
        _(last_response.body).must_equal "Core\nDNS\nDev-Go\nDev-HTTP\nNeovim\nPrivacy\nPython\nVim"
        _(last_response.content_type).must_equal 'text/plain'
      end
    end

    describe 'when searching brewfiles' do
      it 'returns matching brewfiles' do
        get '/api/search/go'
        _(last_response.status).must_equal 200
        _(last_response.body).must_equal "Dev-Go"
        _(last_response.content_type).must_equal 'text/plain'
      end

      it 'returns empty string when no matches' do
        get '/api/search/nonexistent'
        _(last_response.status).must_equal 200
        _(last_response.body).must_equal ""
        _(last_response.content_type).must_equal 'text/plain'
      end

      it 'supports multiple search terms' do
        get '/api/search/dev,vim'
        _(last_response.status).must_equal 200
        # Results may include any brewfile containing any of the search terms
        # Verify each expected term is in the response
        _(last_response.body).must_include "Dev-Go"
        _(last_response.body).must_include "Dev-HTTP"
        _(last_response.body).must_include "Vim"
        _(last_response.content_type).must_equal 'text/plain'
      end
    end

    describe 'when generating brewfiles' do
      it 'generates a combined brewfile' do
        get '/api/generate/Neovim,Privacy'
        _(last_response.status).must_equal 200
        _(last_response.body).must_include '# brewfile.io'
        _(last_response.body).must_include '# Generated from Neovim, Privacy'
        _(last_response.body).must_include 'brew install neovim'
        _(last_response.body).must_include 'brew install privoxy'
        _(last_response.body).must_include 'brew tap neovim/neovim'
        _(last_response.content_type).must_equal 'text/plain'
      end

      it 'returns 400 when no brewfile names provided' do
        get '/api/generate/'
        _(last_response.status).must_equal 400
        _(last_response.body).must_equal '{"errors":["Need ≥ 1 Brewfile names"]}'

        get '/api/generate'
        _(last_response.status).must_equal 400
        _(last_response.body).must_equal '{"errors":["Need ≥ 1 Brewfile names"]}'
      end

      it 'returns empty string when brewfile not found' do
        get '/api/generate/NonExistent'
        _(last_response.status).must_equal 200
        # Should just show the header without any package entries
        expected_header = "# brewfile.io\n# Generated from \n"
        _(last_response.body).must_equal expected_header
        _(last_response.content_type).must_equal 'text/plain'
      end
    end
  end

  describe 'not found handling' do
    it 'returns 404 for unknown routes' do
      get '/unknown'
      _(last_response.status).must_equal 404
      _(last_response.body).must_equal ''
    end
  end

  describe 'request metadata' do
    it 'sets timing information' do
      get '/health'
      _(last_response.headers).must_include 'X-Request-ID'
      # Cannot test the exact value as it's randomly generated
      _(last_response.headers['X-Request-ID']).wont_be_nil
    end
  end
end