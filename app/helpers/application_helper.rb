module ApplicationHelper

  def icon(key, options = {})
    opts = {:class => "fa fa-#{key}"}.merge(options)
    content_tag(:span, "", opts).html_safe
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