require 'inch_ci/controller'
require 'inch_ci/badge'

class ProjectsController < ApplicationController
  include InchCI::Controller

  layout :determine_layout
  skip_before_action :verify_authenticity_token, :only => [:rebuild_via_hook]

  def badge
    view = Action::Project::Badge.new(params)
    if view.project.nil?
      render :text => "Project not found.", :layout => false, :status => 404
    else
      if view.branch.nil?
        render :text => "Branch not found.", :layout => false, :status => 404
      else
        send_file view.badge_filename, :content_type => view.content_type, :disposition => 'inline'
      end
    end
  end

  def create
    action = Action::Project::Create.new(params)
    if action.success?
      redirect_to project_url(action.project, :pending_build => action.build_id)
    else
      expose action
      flash[:error] = t("projects.create.url_not_found")
      render :template => "page/welcome"
    end
  end

  def history
    process_project_action Action::Project::Show
  end

  def rebuild
    action = Action::Project::Rebuild.new(params)
    if action.project.nil?
      render :text => "Project not found.", :layout => false, :status => 404
    else
      redirect_to project_url(action.project, action.branch.name, :pending_build => action.build_id)
    end
  end

  def rebuild_via_hook
    action = Action::Project::RebuildViaHook.new(params)
    render :text => action.result
  end

  def suggestions
    process_project_action Action::Project::Suggestions
  end

  def update_info
    action = Action::Project::UpdateInfo.new(params)
    redirect_to project_url(action.project, action.branch.name)
  end

  def show
    process_project_action Action::Project::Show
  end

  private

  def determine_layout
    case action_name
    when 'create'
      'cover'
    else
      'page'
    end
  end

  def process_project_action(action_class)
    view = action_class.new(params)
    expose view
    if view.project.nil?
      render :text => "Project not found.", :layout => true, :status => 404
    else
      if view.branch.nil?
        render :text => "Branch not found.", :layout => true, :status => 404
      end
    end
  end
end
