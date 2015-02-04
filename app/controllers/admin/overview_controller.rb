class Admin::OverviewController < ApplicationController
  layout 'admin'

  def index
    set_stats
    set_chart_data
    set_projects
  end

  private

  DAYS_BACK = 30
  def set_stats
    list = Statistics.where("date > ?", (DAYS_BACK + 1).days.ago).order('date ASC')
    map = map_stats_to_dates(list)
    @stats_headers = %w(Day Date Badges Users Hooks Users Repos Users)
    @stats = map.keys.sort.map do |date|
      stats = map[date]
      shown_date = date - 1
      [
        shown_date.strftime("%a"),
        shown_date.strftime("%Y-%m-%d"),
        val(stats, 'projects:badges'),
        val(stats, 'maintainers:badges'),
        val(stats, 'projects:hooked'),
        val(stats, 'maintainers:hooked'),
        val(stats, 'projects:all'),
        val(stats, 'maintainers:all'),
      ]
    end
    @stats_badges = stat('projects:badges')
    @stats_badge_users = stat('maintainers:badges')
    @stats_badges_per_user = quotient('projects:badges', 'maintainers:badges')
    @stats_hooks_per_user = quotient('projects:hooked', 'maintainers:hooked')
    @stats_chart_data = map.values
  end

  def set_chart_data
    list = Statistics.order('date ASC').group('name, WEEK(date)')
    map = map_stats_to_dates(list)
    @absolutes_by_week = map.values

    @growth_by_week = []
    @absolutes_by_week.each_with_index do |value, index|
      if index > 0
        last_value = @absolutes_by_week[index-1]
        new_value = {'date' => value['date']}
        value.each do |key, v|
          if v.is_a?(Fixnum)
            new_value[key] = v - last_value[key].to_i
          end
        end
        @growth_by_week << new_value
      end
    end
  end

  # Maps the given list of Statistic objects to their date's day.
  def map_stats_to_dates(list)
    map = {}
    list.each do |stat|
      date = stat.date.midnight
      map[date] ||= {'date' => date.strftime("%Y-%m-%d")}
      map[date][stat.name] = stat.value
    end
    map
  end

  def set_projects
    @new_projects = Project.includes(:default_branch)
                            .where(:badge_generated => true)
                            .order('created_at ASC')
                            .last(30)
  end

  def stat(name)
    Statistics.where(:name => name).last.value
  end

  def quotient(name1, name2, digits = 2)
    (stat(name1).to_f / stat(name2).to_f).round(digits)
  end

  def val(stats, key, add_change = true)
    @old_stats ||= {}
    value = stats[key]
    change = value - @old_stats[key].to_i
    change = "+#{change}" if change > 0
    @old_stats[key] = value
    result = value.to_s
    result << " (#{change})" if add_change
    result
  end

end
