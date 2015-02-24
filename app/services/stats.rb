
class Stats
  def initialize(stats_map)
    @stats = []
    dates = stats_map.keys.sort
    dates.each_with_index do |date, index|
      old_date = index == 0 ? nil : dates[index-1]
      @stats << StatsEntry.new(date, stats_map[date], stats_map[old_date])
    end
    @stats.shift
  end

  def each(&block)
    @stats.each(&block)
  end

  def average(key, use_changes: false)
    values = @stats.map { |entry| entry.value(key) }
    if use_changes
      values = values.map(&:change)
    end
    result = (values.map(&:to_i).inject(:+).to_f / values.size).round(1)
    if use_changes && result > 0
      "+#{result}"
    else
      result.to_s
    end
  end

  class StatsEntry
    def initialize(date, entry, prev_entry = nil)
      @date = date
      @entry = entry
      @prev_entry = prev_entry || {}
      fix_missing_keys
    end

    def value(key, add_change = true)
      value = StatsValue.new(key, @entry[key].to_i, @prev_entry[key].to_i)
    end

    def val(key, add_change = true)
      v = value(key, add_change)
      str = v.to_s
      if add_change
        str << " (#{v.change_prefix}#{v.change})"
      end
      str
    end

    def shown_date
      @date - 1
    end

    private

    def fix_missing_keys
      @entry["projects:badges:ruby"] = @entry["projects:badges"].to_i -
                                       @entry["projects:badges:elixir"].to_i -
                                       @entry["projects:badges:javascript"].to_i
    end
  end

  class StatsValue < Struct.new(:key, :value, :old_value)
    def change
      value - old_value
    end

    def change_prefix
      "+" if change > 0
    end

    def to_i
      value.to_i
    end

    def to_s
      value.to_s
    end
  end

end
