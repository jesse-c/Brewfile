# frozen_string_literal: true

module Bundle
  module Checker
    class BrewServiceChecker < Bundle::Checker::Base
      PACKAGE_TYPE = :brew
      PACKAGE_TYPE_NAME = "Service"
      PACKAGE_ACTION_PREDICATE = "needs to be started."

      def failure_reason(name)
        "#{PACKAGE_TYPE_NAME} #{name} needs to be started."
      end

      def installed_and_up_to_date?(formula)
        return true unless formula_needs_to_start?(entry_to_formula(formula))
        return true if service_is_started?(formula.name)

        old_name = lookup_old_name(formula.name)
        return true if old_name && service_is_started?(old_name)

        false
      end

      def entry_to_formula(entry)
        Bundle::BrewInstaller.new(entry.name, entry.options)
      end

      def formula_needs_to_start?(formula)
        formula.start_service? || formula.restart_service?
      end

      def service_is_started?(service_name)
        Bundle::BrewServices.started?(service_name)
      end

      def lookup_old_name(service_name)
        @old_names ||= Bundle::BrewDumper.formula_oldnames
        old_name = @old_names[service_name]
        old_name ||= @old_names[service_name.split("/").last]
        old_name
      end

      def format_checkable(entries)
        checkable_entries(entries)
      end
    end
  end
end
