class StatsRetriever
  attr_reader :timestamp

  def initialize(timestamp)
    @timestamp = timestamp

    @all_projects = Project.all.where('created_at <= ?', timestamp)
                          .includes(:default_branch)
    default_branches = @all_projects.map(&:default_branch).compact
    current_revisions = default_branches.map { |b|
                          b.revisions.where('created_at <= ?', timestamp).first
                        }.compact
    @with_badges = current_revisions.select(&:badge_in_readme)

    @hooked_projects = []
    default_branches.each do |branch|
      arel = Build.where('created_at <= ?', timestamp)
                  .where(:branch_id => branch.id, :trigger => 'hook')
      if arel.count > 0
        @hooked_projects << branch.project
      end
    end

    @users = @all_projects.map(&:user_name).uniq

    @users_with_badges = @with_badges.map do |revision|
      revision.branch.project.user_name
    end.uniq

    @users_with_hooks = @hooked_projects.map(&:user_name).uniq
  end

  def all_projects
    @all_projects.size
  end

  def with_badges
    @with_badges.size
  end

  def hooked_projects
    @hooked_projects.size
  end

  def users
    @users.size
  end

  def users_with_badges
    @users_with_badges.size
  end

  def users_with_hooks
    @users_with_hooks.size
  end
end

namespace :stats do
  desc "Show stats for the app"
  task :app => :environment do
    timestamp = ENV['TIMESTAMP'] ? Date.parse(ENV['TIMESTAMP']) : Time.now.midnight
    stats = StatsRetriever.new(timestamp)

    puts "Projects: #{stats.all_projects} (#{stats.users} maintainers)"
    puts "Badges:   #{stats.with_badges} (#{stats.users_with_badges} maintainers)"
    puts "Hooks:    #{stats.hooked_projects} (#{stats.users_with_hooks} maintainers)"
  end

  desc "Show stats for the app"
  task :daily => :environment do
    puts "Ran stats:daily"
  end
end
