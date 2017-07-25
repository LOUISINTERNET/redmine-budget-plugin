# Hooks to attach to the Redmine Issues.
class BudgetIssueHook  < Redmine::Hook::ViewListener
  include ActionView::Helpers::TranslationHelper

  # Renders the Deliverable subject
  #
  # Context:
  # * :issue => Issue being rendered
  #
  def view_issues_show_details_bottom(context = { })
    if context[:project] and context[:project].module_enabled?('budget_module')
      data = "<td><b>Deliverable :</b></td><td>#{html_escape context[:issue].deliverable.subject unless context[:issue].deliverable.nil?}</td>"
      return "<tr>#{data}<td></td></tr>"
    else
      return ''
    end
  end

  # Renders a select tag with all the Deliverables
  #
  # Context:
  # * :form => Edit form
  # * :project => Current project
  #
  def view_issues_form_details_bottom(context = { })
    unless context[:project] and context[:project].module_enabled?("budget_module")
      return ""
    end

    deliverables = Deliverable.where(project_id: context[:project]).order("subject ASC")
    hidden_ids = deliverables.select(&:hidden?).map(&:id)

    select_options = deliverables.map do |d|
      [d.subject + (d.hidden ? " #{t "label_hidden"}" : ""), d.id]
    end

    select = context[:form].select :deliverable_id, select_options,
                                   { include_blank: true },
                                   { data: { hidden: hidden_ids.to_json } }

    html = ""
    html << javascript_include_tag("budget_issue_hook", plugin: "budget_plugin")
    html << "<p>#{select}<br/>"
    html << "<a id='show-hidden-deliverables'>#{t "label_show_hidden"}</a>"
    html << "<a id='hide-hidden-deliverables' style='display:none'>#{t "label_hide_hidden"}</a>"
    html << "</p>"
  end

  # Renders a select tag with all the Deliverables for the bulk edit page
  #
  # Context:
  # * :project => Current project
  #
  def view_issues_bulk_edit_details_bottom(context = { })
    project = context[:project] || \
              context[:hook_caller].instance_eval { @target_project }

    if project and project.module_enabled?('budget_module')
      deliverables = Deliverable.where(project_id: project.id).order('subject ASC')

      select = select_tag('deliverable_id',
                               content_tag('option', t(:label_no_change_option), :value => '') +
                               content_tag('option', t(:label_none), :value => 'none') +
                               options_from_collection_for_select(deliverables, :id, :subject))

      return content_tag(:p, content_tag(:label, t(:field_deliverable)) + select)
    else
      return ''
    end
  end

  def set_deliverable_on_issue(context)
    if context[:params] && context[:params][:issue]
      if context[:params][:issue][:deliverable_id].present?
        context[:issue].deliverable = Deliverable.find_by(id: context[:params][:issue][:deliverable_id].to_i, project_id: context[:issue].project.id)
      elsif context[:params][:issue][:deliverable_id] == ''
        context[:issue].deliverable = nil
      end
    end
    return ''
  end

  def controller_issues_new_before_save(context = {})
    set_deliverable_on_issue(context)
  end

  def controller_issues_edit_before_save(context = {})
    set_deliverable_on_issue(context)
  end

  # Saves the Deliverable assignment to the issue
  #
  # Context:
  # * :issue => Issue being saved
  # * :params => HTML parameters
  #
  def controller_issues_bulk_edit_before_save(context = { })
    case true

    when context[:params][:deliverable_id].blank?
      # Do nothing
    when context[:params][:deliverable_id] == 'none'
      # Unassign deliverable
      context[:issue].deliverable = nil
    else
      context[:issue].deliverable = Deliverable.find(context[:params][:deliverable_id])
    end

    return ''
  end

  # Deliverable changes for the journal use the Deliverable subject
  # instead of the id
  #
  # Context:
  # * :detail => Detail about the journal change
  #
  def helper_issues_show_detail_after_setting(context = { })
    # TODO Later: Overwritting the caller is bad juju
    detail = context[:detail]

    unless detail.prop_key == 'deliverable_id'
      return
    end

    # The regex ensures that we don't try to call find with something that
    # isn't an id. This is necessary because detail.value or detail.old_value
    # will already be the deliverable subject sometimes.

    unless detail.value.nil? or detail.value =~ /[^0-9]+/
      d = Deliverable.find(detail.value)
      detail.value = d.subject unless d.nil? || d.subject.nil?
    end

    unless detail.old_value.nil? or detail.old_value =~ /[^0-9]+/
      d = Deliverable.find(detail.old_value)
      detail.old_value = d.subject unless d.nil? || d.subject.nil?
    end
  end
end
