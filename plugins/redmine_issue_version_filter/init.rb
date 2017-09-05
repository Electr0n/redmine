require 'redmine'
require 'redmine_issue_version_filter'
require_dependency 'redmine_issue_version_filter/hooks'

Redmine::Plugin.register :redmine_issue_version_filter do
  name 'Redmine Open Version Filter plugin'
  author 'Electr0n'
  description "This plugin adds new filter 'version' for issue controller"
  version '0.0.1'
  url 'https://github.com/Electr0n/redmine/redmine_issue_version_filter'
  author_url 'https://github.com/Electr0n'
end