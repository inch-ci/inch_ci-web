module ProjectsHelper
  def link_to_build_history(project)
    url = project_build_history_path(project)
    link = link_to(t("projects.topbar.info.builds_link"), url)
    t("projects.topbar.info.builds_all", :link => link).html_safe
  end

  def link_to_project(project)
    link_to project.name, project_page_path(project)
  end

  def link_to_branch(branch)
    project = branch.project
    link_to truncate(branch.name), project_page_path(project, branch.name)
  end

  def link_to_revision(revision)
    branch = revision.branch
    project = branch.project
    link_to revision.uid[0..7], project_page_path(project, branch.name, revision.uid)
  end

  def link_to_with_hostname(url, options)
    hostname = URI.parse(url).host.gsub(/^www\./, '')
    link_to hostname, url, options
  end
end
