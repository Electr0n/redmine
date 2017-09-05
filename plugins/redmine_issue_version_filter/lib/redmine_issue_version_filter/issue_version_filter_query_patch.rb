module IssueVersionFilterQueryPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable

      alias_method_chain :available_filters, :issue_version_filter
    end
  end

  module InstanceMethods

    def shared_versions_ids
      projects = project && project.self_and_descendants
      if projects
        all_shared_version_ids = projects.map(&:shared_versions).flatten.map(&:id).uniq
      end
    end

    # add filters
    def available_filters_with_issue_version_filter
      filters = available_filters_without_issue_version_filter
      
      filters.merge!('issue_version_filter' =>
        {
          :name => l('field_issue_version_filter'),
          :type => l('field_issue_version_filter'),
          :order => 2,
          :values => shared_versions_ids,
        })
    end

    def sql_for_issue_version_filter_field(field, operator, value)
      scope = Version
      
      if shared_versions_ids
        scope = scope.where(id: shared_versions_ids)
      end

      version_ids = scope.open.visible.all().collect(&:id).push(0)
      iss_ids = Issue.where(("fixed_version_id " + operator + " ? "), value).collect(&:id)

      case self.type
      when 'IssueQuery'
        if iss_ids.empty?
          "(#{Issue.table_name}.id IS NULL)"
        else
          "(#{Issue.table_name}.id IN (#{iss_ids.join(',')}))"
        end
      when 'TimeEntryQuery'
        if iss_ids.empty?
          "(#{TimeEntry.table_name}.issue_id IS NULL)"
        else
          "(#{TimeEntry.table_name}.issue_id IN (#{iss_ids.join(',')}))"
        end
      end

    end

  end

end