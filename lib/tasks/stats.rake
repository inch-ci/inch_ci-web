namespace :stats do
  desc "Show stats for the app"
  task :app => :environment do
    all_projects = Project.all.includes(:default_branch)
    default_branches = all_projects.map(&:default_branch).compact
    latest_revisions = default_branches.map(&:latest_revision).compact
    with_badges = latest_revisions.select(&:badge_in_readme)

    hooked_projects = []
    default_branches.each do |branch|
      if Build.where(:branch_id => branch.id, :trigger => 'hook').count > 0
        hooked_projects << branch.project
      end
    end

    users = all_projects.map(&:user_name).uniq

    users_with_badges = with_badges.map do |revision|
      revision.branch.project.user_name
    end.uniq

    users_with_hooks = hooked_projects.map(&:user_name).uniq

    puts "Projects: #{all_projects.size} (#{users.size} maintainers)"
    puts "Badges:   #{with_badges.size} (#{users_with_badges.size} maintainers)"
    puts "Hooks:    #{hooked_projects.size} (#{users_with_hooks.size} maintainers)"
  end
end
