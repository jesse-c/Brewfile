# frozen_string_literal: true

module Bundle
  module Checker
    class MacAppStoreChecker < Bundle::Checker::Base
      PACKAGE_TYPE = :mas
      PACKAGE_TYPE_NAME = "App"

      def installed_and_up_to_date?(id)
        Bundle::MacAppStoreInstaller.app_id_installed_and_up_to_date? id
      end

      def format_checkable(entries)
        checkable_entries(entries).map { |e| [e.options[:id], e.name] }
                                  .to_h
      end

      def exit_early_check(app_ids_with_names)
        work_to_be_done = app_ids_with_names.find do |id, _name|
          !installed_and_up_to_date?(id)
        end

        Array(work_to_be_done)
      end

      def full_check(app_ids_with_names)
        app_ids_with_names.reject { |id, _name| installed_and_up_to_date? id }
                          .map { |_id, name| failure_reason(name) }
      end
    end
  end
end
