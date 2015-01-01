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

  def val(stats, key, add_change = true)
    @old_stats ||= {}
    value = stats[key]
    change = value - @old_stats[key].to_i
    change = "+#{change}" if change > 0
    @old_stats[key] = value
    result = value.to_s.rjust(4)
    result << " (#{change})".ljust(6).color(:dark) if add_change
    result
  end

  desc "Show stats for the app"
  task :app => :environment do
    DAYS_BACK = 14
    list = Statistics.where("date > ?", (DAYS_BACK + 1).days.ago).order('date ASC')
    map = {}
    list.each do |stat|
      map[stat.date.midnight] ||= {}
      map[stat.date.midnight][stat.name] = stat.value
    end
    puts "Read: date, badges/maintainers, hooks/maintainers".cyan
    lines = map.keys.sort.map do |date|
      stats = map[date]
      [
        date.strftime("%a, %Y-%m-%d") + " ",
        val(stats, 'projects:badges'),
        val(stats, 'maintainers:badges'),
        val(stats, 'projects:hooked'),
        val(stats, 'maintainers:hooked'),
        #val(stats, 'projects:all'),
        #val(stats, 'maintainers:all'),
      ].join("")
    end
    lines.shift # first row has changes calculated against zero
    puts lines.join("\n")
  end

  desc "Show stats for the app"
  task :daily => :environment do
    timestamp = ENV['TIMESTAMP'] ? Date.parse(ENV['TIMESTAMP']) : Time.now.midnight
    stats = StatsRetriever.new(timestamp)

    store = InchCI::Store::CreateStats
    store.call("projects:all", stats.all_projects, timestamp)
    store.call("projects:badges", stats.with_badges, timestamp)
    store.call("projects:hooked", stats.hooked_projects, timestamp)
    store.call("maintainers:all", stats.users, timestamp)
    store.call("maintainers:badges", stats.users_with_badges, timestamp)
    store.call("maintainers:hooked", stats.users_with_hooks, timestamp)
  end
end
