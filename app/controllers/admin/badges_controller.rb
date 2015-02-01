class Admin::BadgesController < ApplicationController
  layout 'admin'

  def added
    @date_from = Date.parse(params[:date_from])
    @date_to = Date.parse(params[:date_to])
    @projects_from = projects_with_badges_before(@date_from)
    @projects_to = projects_with_badges_before(@date_to)
    @projects = @projects_to - @projects_from
  end

  def in_readme
    @projects = projects_with_badges_before(Time.now)
  end

  private

  def projects_with_badges_before(timestamp)
    Project.all.where(:badge_in_readme => true)
      .where('created_at <= ?', timestamp)
      .where('badge_in_readme_added_at <= ?', timestamp)
  end
end
