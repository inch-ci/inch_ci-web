class ProjectPresenter < BasePresenter
  def_delegators :project, :uid, :name, :description
  def_delegators :project, :homepage_url, :source_code_url, :repo_url, :documentation_url
  def_delegators :project, :language, :origin
  def_delegators :project, :service_name, :user_name, :repo_name
  def_delegators :project, :created_at, :updated_at

  def_delegators :project, :default_branch, :branches

end
