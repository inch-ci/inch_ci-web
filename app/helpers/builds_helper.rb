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
      'cancelled' => :cancelled,
    }[build.status] || :danger
  end

  def build_status_icon(build)
    key = build_status_icon_map[build.status]
    title = t("builds.status.#{build.status}", :default => build.status)
    icon(key || :question, :title => title)
  end

  def build_status_icon_map
    {
      'created' => :"circle-o",
      'cancelled' => :"arrow-up",
      'duplicate' => :"check-square",
      'running' => :"spinner fa-pulse",
      'success' => :check,
      'failed:retriever' => :exclamation,
    }
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
      'shell' => :terminal,
      'travis' => :"cloud-upload",
    }
  end
end
