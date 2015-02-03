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
    if params[:language]
      arel = arel.where('LOWER(language) = ?', params[:language].to_s.downcase)
    end
    if params[:badge_in_readme]
      arel = arel.where(:badge_in_readme => true)
    end
    if params[:badge_generated]
      arel = arel.where(:badge_generated => true)
    end
    if filled = params[:badge_filled_greater_than]
      arel = arel.where('badge_filled_in_percent >= ?', filled)
    end
    if uid = params[:uid]
      arel = arel.where('uid LIKE ?', "%#{uid}%")
    end
    if service = params[:service]
      like = "#{service}:"
      if user_name = params[:user]
        like << "#{user_name}/"
      end
      arel = arel.where('uid LIKE ?', like+'%')
    end
    arel
  end
end
