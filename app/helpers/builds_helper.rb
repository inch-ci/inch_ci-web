module BuildsHelper
  def back_button(path)
    link_to icon('arrow-left') + ' ' + t("shared.back_link"), path, :class => "btn btn-default btn-cancel"
  end

  def build_css_class(build)
    {
      'created' => '',
      'running' => :info,
      'success' => :success,
      'duplicate' => :warning,
    }[build.status] || :danger
  end

  def build_status_icon(build)
    key = {
      'created' => :"circle-o",
      'running' => :"dot-circle-o",
      'duplicate' => :"check-square",
      'success' => :check,
      'failed:retriever' => :exclamation,
    }[build.status]
    icon(key || :question, :title => build.status)
  end

  def build_trigger_icon(build)
    key = build_trigger_icon_map[build.trigger]
    icon(key || :question, :title => build.trigger)
  end

  def build_trigger_icon_map
    {
      'cron' => :"clock-o",
      'hook' => :git,
      'manual' => :user,
      'tag_build' => :tags,
      'travis' => :"cloud-upload",
    }
  end

  def dashboard_table_project_class(project)
    classes = []
    classes << :new if project.created_at > 1.day.ago
    classes.join(' ')
  end
end
