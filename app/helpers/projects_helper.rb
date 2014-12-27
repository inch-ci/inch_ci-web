module ProjectsHelper
  def badge_markup
    @badge_markup ||= BadgeMarkup.new(@project, @branch)
  end

  def escape_markdown(str)
    str.to_s.gsub('_', '\_')
  end

  def tweet_url(project = nil)
    url = project ? project_url(project) : root_url
    text = project ? t("shared.twitter_text", :project_language => project.language, :project_name => project.name) : t("shared.twitter_text_wo_project")
    "https://twitter.com/share?url=#{url}&text=#{text} &via=InchCI"
  end

  def github_issue_url(options = {})
    title = ''
    if project = options[:project]
      p_url = project_url(project)
      body = "\n\n---\nRe: [#{project.name}](#{p_url})"
      if code_object = options[:code_object]
        c_url = code_object_url(project, options[:branch].name, options[:revision].uid[0..7], :code_object => code_object)
        body = "\n\n---\nRe: [#{code_object.grade}] [#{code_object.fullname}](#{c_url}) in [#{project.name}](#{p_url})"
      end
    end
    "https://github.com/inch-ci/inch_ci-web/issues/new?title=#{URI.escape(title)}&body=#{URI.escape(body)}"
  end

  def link_to_build_history(project)
    url = project_build_history_path(project)
    link = link_to(t("projects.topbar.info.builds_link"), url)
    t("projects.topbar.info.builds_all", :link => link).html_safe
  end

  def link_to_project(project, text = project.name)
    link_to text, project_path(project)
  end

  def link_to_branch(branch)
    project = branch.project
    link_to truncate(branch.name), project_path(project, branch.name)
  end

  def link_to_revision(revision)
    branch = revision.branch
    project = branch.project
    link_to revision.uid[0..7], project_path(project, branch.name, revision.uid)
  end

  def link_to_subnavi(action, path, i18n_opts = {})
    text = t("projects.subnavi.#{action}", i18n_opts)
    classes = %w(btn btn-default)
    classes << 'active' if controller.action_name == action.to_s
    link_to text.html_safe, path, :class => classes
  end

  def link_to_with_hostname(url, options)
    hostname = URI.parse(url).host.gsub(/^www\./, '')
    link_to hostname, url, options
  end

  def promo_hint
    """
    <!--
Hi there,

this patch adds a docs badge to the README to show off inline-documentation to potential contributors: [![Inline docs](http://inch-ci.org/github/#{@project.name}.svg)](http://inch-ci.org/github/#{@project.name})

The badge links to [Inch CI](http://inch-ci.org), a project that tries to raise the visibility of inline-docs to encourage aspiring Rubyists to document their code. Your status page is http://inch-ci.org/github/#{@project.name}/

Inch CI is still in its infancy, but already used by projects like [Bundler](https://github.com/bundler/bundler), [Guard](https://github.com/guard/guard), [Haml](https://github.com/haml/haml), [Pry](https://github.com/pry/pry), and [ROM](https://github.com/rom-rb/rom).

What do you think?
    -->
    """
  end

  def show_rebuild_link?
    @project.build_on_inch_ci?
  end
end
