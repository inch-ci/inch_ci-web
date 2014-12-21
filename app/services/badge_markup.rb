class BadgeMarkup < Struct.new(:project, :branch)
  BASE_URL = "http://inch-ci.org"
  IMAGE_FORMATS = [:svg, :png]
  DEFAULT_IMAGE_FORMAT = IMAGE_FORMATS.first
  IMAGE_STYLES = ['flat', 'flat-square', nil]

  def each(format = DEFAULT_IMAGE_FORMAT, style = nil, &block)
    format_map(format, style).each(&block)
  end

  def image_formats
    IMAGE_FORMATS
  end

  def image_path(format = DEFAULT_IMAGE_FORMAT, style = nil)
    base = "#{page_path}.#{format}?branch=#{branch.name}"
    base << "&style=#{style}" if style
    base
  end

  def image_url(format = DEFAULT_IMAGE_FORMAT, style = nil)
    "#{BASE_URL}#{image_path(format, style)}"
  end

  def styles
    IMAGE_STYLES
  end

  private

  def format_map(format, style = nil)
    image = image_url(format, style)
    link  =  page_url
    alt   = "Inline docs"
    {
      :image_url  => "#{image}",
      :md         => "[![#{alt}](#{image})](#{link})",
      :textile    => "!#{image}!:#{link}",
      :rdoc       => "{<img src=\"#{image}\" alt=\"#{alt}\" />}[#{link}]",
    }
  end

  def page_path
    "/#{project.service_name}/#{project.user_name}/#{project.repo_name}"
  end

  def page_url
    "#{BASE_URL}#{page_path}"
  end
end
