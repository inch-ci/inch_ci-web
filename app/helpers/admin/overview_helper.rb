module Admin::OverviewHelper
  def created_at_classes(project)
    today = Time.now.utc.midnight
    created = project.created_at.midnight
    [
      created == today ? 'today' : nil,
      created == today - 1 ? 'yesterday' : nil,
    ]
  end
end
