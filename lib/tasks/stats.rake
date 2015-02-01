class StatsRetriever
  attr_reader :timestamp

  def initialize(timestamp)
    @timestamp = timestamp
    @all_projects = Project.all.where('created_at <= ?', timestamp)
                          .includes(:default_branch)
    calc_project_and_badge_usage_stats
    calc_maintainers_stats
    calc_user_stats
    calc_serve_stats
  end

  #
  # Project and badges stats
  #
  def calc_project_and_badge_usage_stats
    @projects_with_badges = @all_projects
                              .where('badge_in_readme_added_at <= ?', @timestamp)
                              .where('badge_in_readme_removed_at IS NULL OR badge_in_readme_removed_at > ?', @timestamp)

    @hooked_projects = []
    default_branches = @all_projects.map(&:default_branch).compact
    default_branches.each do |branch|
      arel = Build.where('created_at <= ?', @timestamp)
                  .where(:branch_id => branch.id, :trigger => 'hook')
      if arel.count > 0
        @hooked_projects << branch.project
      end
    end
  end

  #
  # Project-based maintainer stats
  # ('users' being signed in users of Inch CI and maintainers being people/organisations identified via project names)
  #
  def calc_maintainers_stats
    @maintainers = @all_projects.map(&:user_name).uniq
    @maintainers_with_badges = @projects_with_badges.map(&:user_name).uniq
    @maintainers_with_hooks = @hooked_projects.map(&:user_name).uniq
  end

  # User stats
  # ('users' being signed in users of Inch CI and maintainers being people/organisations identified via project names)
  #
  def calc_user_stats
    @users_connected_via_github = User.where(:provider => 'github').where('created_at <= ?', @timestamp)
    @users_signed_in_last24h = User.where('last_signin_at > ? AND last_signin_at <= ?', @timestamp-24.hours, @timestamp)
  end

  def calc_serve_stats
    timestamp = (@timestamp - 24.hours).strftime('%Y-%m-%d')
    @badges_served_in_last24h = `grep "#{timestamp}" log/production.log | grep -c "Processing by ProjectsController#badge as"`
    builds_in_last24h = Build.where('created_at > ? AND created_at <= ?', @timestamp-24.hours, @timestamp)
    @manual_builds_in_last24h = builds_in_last24h.select { |b| b.trigger == 'manual' }
    @hooked_builds_in_last24h = builds_in_last24h.select { |b| b.trigger == 'hook' }
    @travis_builds_in_last24h = builds_in_last24h.select { |b| b.trigger == 'travis' }
  end

  def all_projects
    @all_projects.size
  end

  def with_badges
    @projects_with_badges.size
  end

  def elixir_with_badges
    @projects_with_badges.select { |p| p.language.to_s.downcase == 'elixir' }.size
  end

  def javascript_with_badges
    @projects_with_badges.select { |p| p.language.to_s.downcase == 'javascript' }.size
  end

  def hooked_projects
    @hooked_projects.size
  end

  def maintainers
    @maintainers.size
  end

  def maintainers_with_badges
    @maintainers_with_badges.size
  end

  def maintainers_with_hooks
    @maintainers_with_hooks.size
  end

  def users_connected_via_github
    @users_connected_via_github.size
  end

  def users_signed_in_last24h
    @users_signed_in_last24h.size
  end

  def badges_served_in_last24h
    @badges_served_in_last24h.to_i
  end

  def manual_builds_in_last24h
    @manual_builds_in_last24h.size
  end

  def hooked_builds_in_last24h
    @hooked_builds_in_last24h.size
  end

  def travis_builds_in_last24h
    @travis_builds_in_last24h.size
  end
end

namespace :stats do
  def store_stats(timestamp, stats, store = nil, &block)
    store = store || block

    store.call("projects:all", stats.all_projects, timestamp)
    store.call("projects:badges", stats.with_badges, timestamp)
    store.call("projects:badges:elixir", stats.elixir_with_badges, timestamp)
    store.call("projects:badges:javascript", stats.javascript_with_badges, timestamp)
    store.call("projects:hooked", stats.hooked_projects, timestamp)
    store.call("maintainers:all", stats.maintainers, timestamp)
    store.call("maintainers:badges", stats.maintainers_with_badges, timestamp)
    store.call("maintainers:hooked", stats.maintainers_with_hooks, timestamp)
    store.call("users:github", stats.users_connected_via_github, timestamp)
    store.call("users:signins:<24h", stats.users_signed_in_last24h, timestamp)
    store.call("badges:served:<24h", stats.badges_served_in_last24h, timestamp)
    store.call("builds:manual:<24h", stats.manual_builds_in_last24h, timestamp)
    store.call("builds:hooked:<24h", stats.hooked_builds_in_last24h, timestamp)
    store.call("builds:travis:<24h", stats.travis_builds_in_last24h, timestamp)
  end

  desc "Show stats for the app"
  task :live => :environment do
    timestamp = ENV['TIMESTAMP'] ? Date.parse(ENV['TIMESTAMP']) : Time.now.midnight

    stats = StatsRetriever.new(timestamp)
    store_stats(timestamp, stats) do |name, count, timestamp|
      formatted = timestamp.strftime('%Y-%m-%d')
      puts "#{formatted}\t#{name.ljust(20)}\t#{count.to_s.rjust(5)}"
    end
  end

  desc "Fixes stats for past TIMESTAMP"
  task :fix => :environment do
    timestamp = ENV['TIMESTAMP'] ? Date.parse(ENV['TIMESTAMP']) : Time.now.midnight

    stats = StatsRetriever.new(timestamp)
    store_stats(timestamp, stats, InchCI::Store::CreateOrUpdateStats)
  end

  desc "Show stats for the app"
  task :daily => :environment do
    timestamp = ENV['TIMESTAMP'] ? Date.parse(ENV['TIMESTAMP']) : Time.now.midnight

    stats = StatsRetriever.new(timestamp)
    store_stats(timestamp, stats, InchCI::Store::CreateStats)
  end
end
