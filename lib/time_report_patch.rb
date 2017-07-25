require_dependency 'redmine/helpers/time_report'

# Patches Redmine's TimeReport Helper dynamically, adding the Deliverable
# to the available criteria
module TimeReportPatch
  def self.included(base) # :nodoc:

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      alias_method_chain :load_available_criteria, :deliverable
    end

  end

  module InstanceMethods

    # Wrapper around the +load_available_criteria+ to add a new Deliverable criteria
    def load_available_criteria_with_deliverable
      load_available_criteria_without_deliverable

      @available_criteria["deliverable_id"] = {
        :sql => "#{Issue.table_name}.deliverable_id",
        :klass => Deliverable,
        :label => :field_deliverable
      }

      @available_criteria
    end
  end
end


