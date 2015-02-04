desc "Regenerates all badges in all styles for all projects"
task :badges => :environment do
  projects = Project.all
  projects = [Project.find_by_uid(ENV['PROJECT_UID'])] if ENV['PROJECT_UID']
  projects.each do |project|
    project.branches.each do |branch|
      if revision = branch.latest_revision
        code_objects = revision.code_objects
        InchCI::Worker::Project::Build::GenerateBadge.call(project, branch, code_objects)
      end
    end
  end
end

desc "Update badge related fields for all projects"
task :update_badge_fields => :environment do
  projects = if ENV['PROJECT_UID']
      [Project.find_by_uid(ENV['PROJECT_UID'])]
    else
      Project.includes(:default_branch).references(:default_branch).where('default_branch_id IS NOT NULL AND `branches`.latest_revision_id IS NOT NULL')
    end

  projects.each do |project|
    puts project.uid
    branch = project.default_branch
    revision = branch.latest_revision
    if revision
      # badge exists
      relevant_code_objects = InchCI::Store::FindRelevantCodeObjects.call(revision)
      undocumented_code_objects = relevant_code_objects.select { |code_object| code_object.grade == 'U' }

      project.badge_generated = true
      project.badge_in_readme = revision.badge_in_readme
      if relevant_code_objects.size > 0
        project.badge_filled_in_percent = 100 - (undocumented_code_objects.size / relevant_code_objects.size.to_f * 100).to_i
      end

      earliest_revision_with_badge = branch.revisions
                                      .where('badge_in_readme = ?', true).last
      if earliest_revision_with_badge
        project.badge_in_readme_added_at = earliest_revision_with_badge.created_at
        later_revision_without_badge = branch.revisions
                                        .where('badge_in_readme = ? AND created_at > ?', false, earliest_revision_with_badge.created_at).last
        if later_revision_without_badge
          project.badge_in_readme_removed_at = later_revision_without_badge.created_at
        end
      end
      project.save
    end
  end
end
