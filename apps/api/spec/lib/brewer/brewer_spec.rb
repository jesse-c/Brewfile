# frozen_string_literal: true

require 'minitest/autorun'
require './lib/brewer/brewer'

describe Brewer do
  before do
    @brewer = Brewer.new
  end

  describe 'when searching' do
    it 'finds nothing' do
      _(@brewer.search(%w[z])).must_equal ''
    end

    it 'finds something' do
      _(@brewer.search(%w[v Privacy])).must_equal %w[Neovim Dev-HTTP Dev-Go Privacy Vim Dev-All].join("\n")
    end
  end

  describe 'when listing' do
    it 'lists all brewfiles' do
      _(@brewer.list).must_equal %w[All Neovim Dev-HTTP Python Dev-Go Privacy Vim DNS Dev-All Core].join("\n")
    end
  end

  describe 'when generating' do
    it 'generates a combined brewfile' do
      _(@brewer.generate(%w[Neovim Privacy])).must_equal "# brewfile.io\n# Generated from Neovim, Privacy\n\nbrew tap neovim/neovim \nbrew install neovim \nbrew install privoxy"
    end
  end

  describe 'stripping extensions' do
    it 'strips the extension' do
      _(@brewer.strip_ext('Dev.Brewfile')).must_equal 'Dev'
    end
  end
end
