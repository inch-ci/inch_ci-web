require 'inch_ci/controller'

class Admin::ProjectsController < ApplicationController
  include InchCI::Controller

  PROJECTS_PER_PAGE = 200
  LANGUAGE_NOT_SET = "LANGUAGE_NOT_SET"

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

  def update
    @project = ::Project.find(params[:id])
    attributes = params[:project]
    @project.documentation_url = attributes[:documentation_url]
    @project.language = attributes[:language]
    InchCI::Store::SaveProject.call(@project)
    redirect_to admin_project_url(@project)
  end

  def index
    @projects = find_projects
    @languages = %w(Elixir JavaScript Ruby) + [LANGUAGE_NOT_SET]
  end

  def find_projects
    arel = filter_collection(Project).order('created_at DESC')
    @projects_total_count = arel.count
    arel.limit(PROJECTS_PER_PAGE)
  end

  def show
    @project = Project.find(params[:id])
  end

  private

  def filter_collection(arel)
    if params[:language].present?
      if params[:language] == LANGUAGE_NOT_SET
        arel = arel.where('language IS NULL')
      else
        arel = arel.where('LOWER(language) = ?', params[:language].to_s.downcase)
      end
    end
    if params[:fork].present?
      arel = arel.where(:fork => params[:fork] == '1')
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

  def filter_by_service_and_user(arel, service, user_name)
    like = "#{service}:"
    if user_name
      like << "#{user_name}/"
    end
    arel.where('uid LIKE ?', like+'%')
  end
end
