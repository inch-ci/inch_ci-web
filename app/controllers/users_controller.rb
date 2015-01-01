require 'inch_ci/controller'

class UsersController < ApplicationController
  include InchCI::Controller

  before_action :require_login

  layout :determine_layout

  def init_projects
    action = Action::User::InitProjects.new(current_user, params)
    expose action
    respond_to do |format|
      format.js
    end
  end

  def sync_projects
    action = Action::User::SyncProjects.new(current_user, params)
    expose action
    respond_to do |format|
      format.html { redirect_to user_url(action.user) }
      format.js
    end
  end

  def show
    action = Action::User::Show.new(current_user, params)
    expose action
  end

  def welcome
    action = Action::User::Welcome.new(current_user)
    expose action
  end

  private

  def determine_layout
    case action_name
    when 'welcome'
      'cover'
    else
      'page'
    end
  end

end
