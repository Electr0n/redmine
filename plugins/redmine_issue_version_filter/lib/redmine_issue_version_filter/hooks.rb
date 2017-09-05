module RedmineIssueVersionFilter
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context={})
      if context[:controller] &&
        (context[:controller].is_a?(IssuesController) || context[:controller].is_a?(QueriesController))
        javascript_include_tag('issue_version_filter.js', :plugin => 'redmine_issue_version_filter')
      end
    end
  end
end