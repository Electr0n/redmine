require 'redmine_issue_version_filter/issue_version_filter_query_patch'
Rails.configuration.to_prepare do
  Query.send(:include, IssueVersionFilterQueryPatch)
end