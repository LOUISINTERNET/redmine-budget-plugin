require_dependency 'issue_query'

# Patches Redmine's Queries dynamically, adding the Deliverable
# to the available query columns
module IssueQueryPatch
  def self.included(base) # :nodoc:

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      base.add_available_column(QueryColumn.new(:deliverable_subject, :sortable => "#{Deliverable.table_name}.subject"))

      alias_method_chain :initialize_available_filters, :deliverable
    end

  end

  module InstanceMethods

    # Wrapper around the +initialize_available_filters+ to add a new Deliverable filter
    def initialize_available_filters_with_deliverable
      initialize_available_filters_without_deliverable

      if project
        deliverable_values = Deliverable.where(project_id: project).order("subject ASC").collect { |d| [d.subject, d.id.to_s]}
        add_available_filter "deliverable_id", :type => :list_optional, :values => deliverable_values
      end
    end
  end
end


