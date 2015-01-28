require 'inch_ci/controller'
require 'inch_ci/badge'

class ProjectsController < ApplicationController
  include InchCI::Controller

  layout :determine_layout

  skip_before_action :verify_authenticity_token, :only => [:rebuild_via_hook]

  def create_hook
    action = Action::Project::ActivateHook.new(current_user, params)
    if !action.success?
      expose action
      flash[:error] = "Could not create hook for #{@project.name}"
    end
    redirect_to user_url(current_user)
  end

  def badge
    action = Action::Project::Badge.new(params)
    if action.success?
      send_file action.badge_filename, :content_type => action.content_type, :disposition => 'inline'
    else
      render :text => "Project or branch not found.", :layout => false, :status => 404
    end
  end

  def create
    action = Action::Project::Create.new(params, :homepage)
    if action.success?
      redirect_to project_url(action.project, :pending_build => action.build_id)
    else
      expose action
      flash[:error] = t("projects.create.url_not_found")
      render :template => "page/welcome"
    end
  end

  def edit
    process_project_action Action::Project::Show
  end

  def update
    action = Action::Project::Update.new(current_user, params)
    if action.success?
      redirect_to project_url(action.project)
    else
      redirect_to edit_project_url(action.project)
    end
  end

  def history
    process_project_action Action::Project::Show
  end

  def rebuild
    action = Action::Project::Rebuild.new(params)
    if action.success?
      redirect_to project_url(action.project, action.branch.name, :pending_build => action.build_id)
    else
      render :text => "Project not found.", :layout => false, :status => 404
    end
  end

  def rebuild_via_hook
    action = Action::Project::RebuildViaHook.new(params)
    render :text => action.result
  end

  def remove_hook
    action = Action::Project::DeactivateHook.new(current_user, params)
    if !action.success?
      expose action
      flash[:error] = "Could not remove hook for #{@project.name}"
    end
    redirect_to user_url(current_user)
  end

  def suggestions
    process_project_action Action::Project::Suggestions
  end

  def update_info
    action = Action::Project::UpdateInfo.new(current_user, params)
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
    action = action_class.new(params)
    expose action
    if action.project.nil?
      render :text => "Project not found.", :layout => true, :status => 404
    else
      if action.branch.nil?
        render :text => "Branch not found.", :layout => true, :status => 404
      end
    end
  end
end
