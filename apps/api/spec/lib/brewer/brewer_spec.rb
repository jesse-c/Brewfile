# frozen_string_literal: true

require "minitest/autorun"
require "./lib/brewer/brewer"

describe Brewer do
  before do
    @brewer = Brewer.new
  end

  describe "when present" do
    it "returns nothing" do
      _(@brewer.present(%w[])).must_equal ""
    end

    it "returns something" do
      _(@brewer.present(%w[Dev-Go Neovim])).must_equal "Dev-Go\nNeovim"
    end
  end

  describe "when searching" do
    it "finds nothing" do
      _(@brewer.search(%w[z])).must_equal []
    end

    it "finds something" do
      _(@brewer.search(%w[v Privacy])).must_equal %w[Dev-Go Dev-HTTP Neovim Privacy Vim]
    end
  end

  describe "when listing" do
    it "lists all brewfiles" do
      _(@brewer.list).must_equal %w[Core DNS Dev-Go Dev-HTTP Neovim Privacy Python Vim]
    end
  end

  describe "when generating" do
    it "generates a combined brewfile" do
      _(@brewer.generate(%w[Neovim Privacy])).must_equal ["# brewfile.io", "# Generated from Neovim, Privacy", "", "brew install neovim", "brew install privoxy", "brew tap neovim/neovim"]
    end
  end

  describe "stripping extensions" do
    it "strips the extension" do
      _(@brewer.strip_ext("Dev.Brewfile")).must_equal "Dev"
    end
  end
end
