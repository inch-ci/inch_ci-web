module ApplicationHelper
  def current_user?(user = @user)
    logged_in? && user && user.id == current_user.id
  end

  def icon(key, options = {})
    opts = options.merge(:class => "fa fa-#{key} #{options[:class]}".strip)
    content_tag(:i, "", opts).html_safe
  end

  def markdown(text)
    renderer = Redcarpet::Markdown.new(TargetBlankRenderer,
      :autolink => true, :space_after_headers => true)
    renderer.render(text).html_safe
  end
end

class TargetBlankRenderer < Redcarpet::Render::HTML
  def initialize(extensions = {})
    super extensions.merge(:link_attributes => {:target => "_blank"})
  end
end