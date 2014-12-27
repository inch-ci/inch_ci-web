class ProjectPresenter < BasePresenter
  def_delegators :project, :uid, :name, :description
  def_delegators :project, :homepage_url, :source_code_url, :repo_url, :documentation_url
  def_delegators :project, :language, :origin
  def_delegators :project, :github_hook_id
  def_delegators :project, :service_name, :user_name, :repo_name
  def_delegators :project, :created_at, :updated_at

  def_delegators :project, :default_branch, :branches, :builds

  def badge?
    default_branch && !default_branch.latest_revision_id.nil?
  end

  def build_on_inch_ci?
    InchCI::Worker::Project.build_on_inch_ci?(project.language)
  end

  def build_on_travis?
    !build_on_inch_ci?
  end

  def hooked?
    !project.github_hook_id.nil?
  end

  def language?(language)
    project.language.to_s.underscore == language.to_s.underscore
  end

  def name_without_owner
    name.split('/').last
  end
end
