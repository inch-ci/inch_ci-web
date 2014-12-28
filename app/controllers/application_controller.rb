class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def featured_projects
    @featured_projects ||= FEATURED_PROJECT_UIDS.map do |uid|
      InchCI::Store::FindProject.call(uid)
    end.compact
  end
  helper_method :featured_projects

  def code_object_path(*args)
    project_path(*args).merge(:controller => 'code_objects', :action => 'show')
  end
  helper_method :code_object_path

  def code_object_url(*args)
    url_for code_object_path(*args)
  end
  helper_method :code_object_url

  def project_path(project, *args)
    options = args.extract_options!
    branch_name = args.shift
    revision_uid = args.shift
    hash = {
      :controller => '/projects',
      :action => 'show',
      :service => project.service_name,
      :user => project.user_name,
      :repo => project.repo_name,
      :branch => branch_name,
      :revision => revision_uid,
    }
    hash.merge(options)
  end
  helper_method :project_path

  def project_build_history_path(*args)
    project_path(*args).merge(:controller => 'builds', :action => 'index')
  end
  helper_method :project_build_history_path

  def project_history_path(*args)
    project_path(*args).merge(:action => 'history')
  end
  helper_method :project_history_path

  def project_suggestions_path(*args)
    project_path(*args).merge(:action => 'suggestions')
  end
  helper_method :project_suggestions_path

  def project_rebuild_path(*args)
    project_path(*args).merge(:action => 'rebuild')
  end
  helper_method :project_rebuild_path

  def project_update_info_path(*args)
    project_path(*args).merge(:action => 'update_info')
  end
  helper_method :project_update_info_path

  def project_url(*args)
    url_for project_path(*args)
  end
  helper_method :project_url

  def signin_path(provider = :github)
    "/auth/#{provider}"
  end
  helper_method :signin_path

  def user_path(user, *args)
    options = args.extract_options!
    hash = {
      :controller => '/users',
      :action => 'show',
      :service => user.service_name,
      :user => user.user_name,
    }
    hash.merge(options)
  end
  helper_method :user_path

  def user_url(*args)
    url_for user_path(*args)
  end

  def current_user=(user)
    session[:user_id] = user.id
    user.update_attribute(:last_signin_at, Time.now)
    user
  end

  def current_user
    if session[:user_id]
      @current_user ||= UserPresenter.new(User.find(session[:user_id]))
    end
  end
  helper_method :current_user

  def logged_in?
    !current_user.nil?
  end
  helper_method :logged_in?

  def require_login
    unless logged_in?
      render :text => 'You need to be signed in.'
      false
    end
  end
end
