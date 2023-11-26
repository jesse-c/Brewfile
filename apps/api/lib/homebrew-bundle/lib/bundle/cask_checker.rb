# frozen_string_literal: true

module Bundle
  module Checker
    class CaskChecker < Bundle::Checker::Base
      PACKAGE_TYPE = :cask
      PACKAGE_TYPE_NAME = "Cask"

      def installed_and_up_to_date?(cask)
        Bundle::CaskInstaller.cask_installed_and_up_to_date? cask
      end
    end
  end
end
