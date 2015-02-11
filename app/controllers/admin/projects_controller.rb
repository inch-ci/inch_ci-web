require 'inch_ci/controller'

class Admin::ProjectsController < ApplicationController
  include InchCI::Controller

  layout 'admin'

  def create
    action = Action::Project::Create.new(params, :admin)
    if action.success?
      redirect_to project_url(action.project, :pending_build => action.build_id)
    else
      expose action
      flash[:error] = t("projects.create.url_not_found")
      render :template => "page/welcome"
    end
  end

  PER_PAGE = 200
  def index
    @projects = filter_collection(Project).order('created_at DESC').limit(PER_PAGE)
    @languages = %w(Elixir JavaScript Ruby)
  end

  private

  def filter_collection(arel)
    if params[:language].present?
      arel = arel.where('LOWER(language) = ?', params[:language].to_s.downcase)
    end
    if params[:badge_in_readme].present?
      arel = arel.where(:badge_in_readme => params[:badge_in_readme] == '1')
    end
    if params[:badge_generated].present?
      arel = arel.where(:badge_generated => params[:badge_generated] == '1')
    end
    if filled = params[:badge_filled_greater_than].presence
      arel = arel.where('badge_filled_in_percent >= ?', filled)
    end
    if params[:maintainers_with_badge_in_readme].present?
      projects = Project.where(:badge_in_readme => true)
      likes = projects.map do |project|
        "#{project.service_name}:#{project.user_name}/%"
      end.uniq
      conditions = (['uid LIKE ?'] * likes.size).join(' OR ')
      arel = arel.where(conditions, *likes)
    end
    if uid = params[:uid].presence
      arel = arel.where('uid LIKE ?', "%#{uid}%")
    end
    if params[:service]
      arel = filter_by_service_and_user(arel, params[:service], params[:user])
    end
    arel
  end

  def filter_by_service_and_user(arel, service, user)
    like = "#{service}:"
    if user_name
      like << "#{user_name}/"
    end
    arel.where('uid LIKE ?', like+'%')
  end
end
