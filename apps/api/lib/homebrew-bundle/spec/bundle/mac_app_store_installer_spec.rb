# frozen_string_literal: true

require "spec_helper"

describe Bundle::MacAppStoreInstaller do
  def do_install
    Bundle::MacAppStoreInstaller.install("foo", 123)
  end

  describe ".installed_app_ids" do
    it "shells out" do
      described_class.installed_app_ids
    end
  end

  describe ".app_id_installed_and_up_to_date?" do
    it "returns result" do
      allow(described_class).to receive(:installed_app_ids).and_return([123, 456])
      allow(described_class).to receive(:outdated_app_ids).and_return([456])
      expect(described_class.app_id_installed_and_up_to_date?(123)).to be(true)
      expect(described_class.app_id_installed_and_up_to_date?(456)).to be(false)
    end
  end

  context "when mas is not installed" do
    before do
      allow(Bundle).to receive(:mas_installed?).and_return(false)
    end

    it "tries to install mas" do
      expect(Bundle).to receive(:system).with("brew", "install", "mas").and_return(true)
      expect { do_install }.to raise_error(RuntimeError)
    end

    describe ".outdated_app_ids" do
      it "does not shell out" do
        expect(described_class).not_to receive(:`)
        described_class.reset!
        described_class.outdated_app_ids
      end
    end
  end

  context "when mas is installed" do
    before do
      allow(Bundle).to receive(:mas_installed?).and_return(true)
    end

    describe ".outdated_app_ids" do
      it "returns app ids" do
        expect(described_class).to receive(:`).and_return("foo 123")
        described_class.reset!
        described_class.outdated_app_ids
      end
    end

    context "when mas is not signed in" do
      it "outputs an error" do
        allow(described_class).to receive(:installed_app_ids).and_return([123])
        allow(described_class).to receive(:outdated_app_ids).and_return([123])
        expect(Kernel).to receive(:system).with("mas account &>/dev/null").and_return(false)
        expect { do_install }.to raise_error(RuntimeError)
      end
    end

    context "when mas is signed in" do
      before do
        allow(Bundle).to receive(:mas_signedin?).and_return(true)
        allow(described_class).to receive(:outdated_app_ids).and_return([])
      end

      context "when app is installed" do
        before do
          allow(described_class).to receive(:installed_app_ids).and_return([123])
        end

        it "skips" do
          expect(Bundle).not_to receive(:system)
          expect(do_install).to be(:skipped)
        end
      end

      context "when app is outdated" do
        before do
          allow(described_class).to receive(:installed_app_ids).and_return([123])
          allow(described_class).to receive(:outdated_app_ids).and_return([123])
        end

        it "upgrades" do
          expect(Bundle).to receive(:system).with("mas", "upgrade", "123").and_return(true)
          expect(do_install).to be(:success)
        end
      end

      context "when app is not installed" do
        before do
          allow(described_class).to receive(:installed_app_ids).and_return([])
        end

        it "installs app" do
          expect(Bundle).to receive(:system).with("mas", "install", "123").and_return(true)
          expect(do_install).to be(:success)
        end
      end
    end
  end
end
