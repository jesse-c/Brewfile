# frozen_string_literal: true

require "spec_helper"

describe Bundle::BrewServices do
  describe ".started_services" do
    before do
      described_class.reset!
    end

    it "is empty when brew servies not installed" do
      allow(Bundle).to receive(:services_installed?).and_return(false)
      expect(described_class.started_services).to be_empty
    end

    it "returns started services" do
      allow(Bundle).to receive(:services_installed?).and_return(true)
      allow(described_class).to receive(:`).and_return <<~EOS
        nginx  started  homebrew.mxcl.nginx.plist
        apache stopped  homebrew.mxcl.apache.plist
        mysql  started  homebrew.mxcl.mysql.plist
      EOS
      expect(described_class.started_services).to contain_exactly("nginx", "mysql")
    end
  end

  context "when brew-services is installed" do
    context "stops the service" do
      it "when the service is started" do
        allow(described_class).to receive(:started_services).and_return(%w[nginx])
        expect(Bundle).to receive(:system).with("brew", "services", "stop", "nginx").and_return(true)
        expect(described_class.stop("nginx")).to be(true)
        expect(described_class.started_services).not_to include("nginx")
      end

      it "when the service is already stopped" do
        allow(described_class).to receive(:started_services).and_return(%w[])
        expect(Bundle).not_to receive(:system).with("brew", "services", "stop", "nginx")
        expect(described_class.stop("nginx")).to be(true)
        expect(described_class.started_services).not_to include("nginx")
      end
    end

    it "restarts the service" do
      allow(described_class).to receive(:started_services).and_return([])
      expect(Bundle).to receive(:system).with("brew", "services", "restart", "nginx").and_return(true)
      expect(described_class.restart("nginx")).to be(true)
      expect(described_class.started_services).to include("nginx")
    end
  end
end
