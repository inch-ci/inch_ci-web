class NewsfeedDay
  attr_reader :title, :badges_added, :badges_removed, :not_forked_projects_created

  def initialize(date)
    @day = date.midnight
    @title = @day.strftime("%Y-%m-%d")
    @badges_added = Project.where('badge_in_readme = ? AND badge_in_readme_added_at > ? AND badge_in_readme_added_at <= ?', true, @day, @day+1.day).count
    @badges_removed = Project.where('badge_in_readme = ? AND badge_in_readme_removed_at > ? AND badge_in_readme_removed_at <= ?', false, @day, @day+1.day).count
    @not_forked_projects_created = Project.where('fork = ? AND created_at > ? AND created_at <= ?', false, @day, @day+1.day).count
  end
end