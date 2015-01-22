class Admin::BadgesController < ApplicationController
  layout 'admin'

  def added
    @date_from = Date.parse(params[:date_from])
    @date_to = Date.parse(params[:date_to])
    @projects_from = projects_with_badges_before(@date_from)
    @projects_to = projects_with_badges_before(@date_to)
    @projects = @projects_to - @projects_from
  end

  private

  def projects_with_badges_before(timestamp)
    all_projects = Project.all.where('created_at <= ?', timestamp)
                          .includes(:default_branch)
    default_branches = all_projects.map(&:default_branch).compact
    current_revisions = default_branches.map { |b|
                          b.revisions.where('created_at <= ?', timestamp).first
                        }.compact
    current_revisions.select(&:badge_in_readme).map { |r| r.branch.project }.uniq
  end
end
