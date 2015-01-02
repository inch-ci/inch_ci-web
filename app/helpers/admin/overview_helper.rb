module Admin::OverviewHelper
  def created_at_classes(object)
    today = Time.now.utc.midnight
    created = object.created_at.midnight
    [
      created == today ? 'today' : nil,
      created == today - 1.day ? 'yesterday' : nil,
    ]
  end

  def link_to_user_projects(user, language = nil)
    projects = user.projects
    if language
      projects = projects.where(:language => language)
    end
    link_to projects.size, admin_projects_path(:service => user.provider, :user => user.user_name, :language => language)
  end
end
