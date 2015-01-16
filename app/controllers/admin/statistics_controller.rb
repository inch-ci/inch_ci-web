class Admin::StatisticsController < ApplicationController
  layout 'admin'

  def index
    weeks
  end

  DAYS_BACK = 28
  def days
    set_stats do
      Statistics.where("date > ?", (DAYS_BACK + 1).days.ago)
    end
    render :action => "index"
  end

  WEEKS_BACK = 20
  def weeks
    set_stats do
      Statistics.where("WEEKDAY(date) = 0 AND date > ?", (WEEKS_BACK + 1).weeks.ago)
    end
    render :action => "index"
  end

  private

  def set_stats(&block)
    list = block.call.order('date ASC')
    map = map_stats_to_dates(list)
    @stats_headers = %w(Day Date Badges Ruby Elixir JavaScript Hooks Projects Maintainers w/badges w/hooks Users Signins Badges\ Served Manual\ Builds Hooked\ Builds Travis\ Builds)
    @stats = map.keys.sort.map do |date|
      stats = map[date]
      stats["projects:badges:ruby"] = stats["projects:badges"].to_i -
                                      stats["projects:badges:elixir"].to_i -
                                      stats["projects:badges:javascript"].to_i
      shown_date = date - 1
      [
        shown_date.strftime("%a"),
        shown_date.strftime("%Y-%m-%d"),
        val(stats, "projects:badges"),
        val(stats, "projects:badges:ruby"),
        val(stats, "projects:badges:elixir"),
        val(stats, "projects:badges:javascript"),
        val(stats, "projects:hooked"),
        val(stats, "projects:all"),
        val(stats, "maintainers:all"),
        val(stats, "maintainers:badges"),
        val(stats, "maintainers:hooked"),
        val(stats, "users:github"),
        val(stats, "users:signins:<24h", false),
        val(stats, "badges:served:<24h", false),
        val(stats, "builds:manual:<24h", false),
        val(stats, "builds:hooked:<24h", false),
        val(stats, "builds:travis:<24h", false),
      ]
    end
    @stats.shift
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

  def stat(name)
    Statistics.where(:name => name).last.value
  end

  def quotient(name1, name2, digits = 2)
    (stat(name1).to_f / stat(name2).to_f).round(digits)
  end

  def val(stats, key, add_change = true)
    @old_stats ||= {}
    value = stats[key].to_i
    change = value - @old_stats[key].to_i
    change = "+#{change}" if change > 0
    @old_stats[key] = value
    result = value.to_s
    result << " (#{change})" if add_change
    result
  end

end
