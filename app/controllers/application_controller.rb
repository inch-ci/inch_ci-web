class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

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
      :controller => 'projects',
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

  def project_url(*args)
    url_for project_path(*args)
  end
  helper_method :project_url

  def project_rebuild_path(*args)
    project_path(*args).merge(:action => 'rebuild')
  end
  helper_method :project_rebuild_path

  def project_update_info_path(*args)
    project_path(*args).merge(:action => 'update_info')
  end
  helper_method :project_update_info_path
end
