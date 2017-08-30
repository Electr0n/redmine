module OpenVersionFilterQueryPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable

      alias_method_chain :available_filters, :open_version_filter
    end
  end

  module InstanceMethods

    # add filters
    def available_filters_with_open_version_filter
      filters = available_filters_without_open_version_filter

      filters.merge!('from_versions_open_version_filter' =>
        {
          :name => l('field_in_opened_versions'),
          :order => 1,
          :values => [[l(:in_opened_versions), :in_opened_versions], [l(:out_of_opened_versions), :out_of_opened_versions]],
        })
    end

    def sql_for_from_versions_open_version_filter_field(field, operator, value)
      scope = Version
      projects = project && project.self_and_descendants
      if projects
        all_shared_version_ids = projects.map(&:shared_versions).flatten.map(&:id).uniq
        scope = scope.where(id: all_shared_version_ids)
      end
      # binding.pry
      if value == ["in_opened_versions"]
        version_ids = scope.open.visible.all(:conditions => 'effective_date IS NOT NULL').collect(&:id).push(0)
        if self.type == "TimeEntryQuery"
          iss_ids = Issue.where("fixed_version_id IN (?)", version_ids).collect(&:id)
          "(#{TimeEntry.table_name}.issue_id IN (#{iss_ids.join(',')}))"
        else
          "(#{Issue.table_name}.fixed_version_id IN (#{version_ids.join(',')}))"
        end
        # do not care about operator and value - just add a condition if filter "in_open_versions" is enabled
        # "(#{TimeEntry.table_name}.issue_id IN (SELECT issue_id FROM #{Issue.table_name} WHERE fixed_version_id = IN (#{version_ids.join(',')})))"
      elsif value == ['out_of_opened_versions']
        version_ids = scope.open.visible.all(:conditions => 'effective_date IS NULL').collect(&:id).push(0)
        if self.type == "TimeEntryQuery"
          iss_ids = Issue.where("fixed_version_id IN (?) OR fixed_version_id IS NULL", version_ids).collect(&:id)
          "(#{TimeEntry.table_name}.issue_id IN (#{iss_ids.join(',')}))"
        else
          "(#{Issue.table_name}.fixed_version_id IN (#{version_ids.join(',')}) OR #{Issue.table_name}.fixed_version_id IS NULL)"
        end
        # do not care about operator and value - just add a condition if filter "in_open_versions" is enabled
      end
      # binding.pry

    end

  end

end
