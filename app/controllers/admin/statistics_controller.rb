class Admin::StatisticsController < ApplicationController
  layout 'admin'

  def index
    weeks
  end

  DAYS_BACK = 21
  def days
    set_stats do
      Statistics.where("date > ?", time_units_back_timestamp(:days, DAYS_BACK))
    end
    render :action => "index"
  end

  WEEKS_BACK = 20
  def weeks
    set_stats do
      Statistics.where("WEEKDAY(date) = 0 AND date > ?", time_units_back_timestamp(:weeks, WEEKS_BACK))
    end
    render :action => "index"
  end

  MONTHS_BACK = 24
  def months
    set_stats do
      Statistics.where("DAY(date) = 2 AND date > ?",time_units_back_timestamp(:months, MONTHS_BACK))
    end
    render :action => "index"
  end

  private

  def time_units_back_timestamp(unit, default)
    time_units = time_units_back(default)
    return 0 if time_units == 'all'
    # we shift the first stats, so we have to load 1 additional record
    (time_units.to_i + 1).send(unit).ago
  end

  def time_units_back(default = nil)
    @time_units_back ||= params[:time_units_back] || default
  end
  helper_method :time_units_back

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
        val(stats, "projects:badges", false),
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
    result = value.to_s
    if key == "projects:badges"
      url = url_for(:controller => 'admin/badges', :action => 'added',
        :date_to => stats['date'], :date_from => @old_stats['date'])
      result << " (<a href=\"#{url}\">#{change}</a>)"
    end
    if add_change
      result << " (#{change})"
    end
    @old_stats['date'] = stats['date']
    @old_stats[key] = value
    result.html_safe
  end

end
