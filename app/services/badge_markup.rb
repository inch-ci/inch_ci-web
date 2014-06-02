class BadgeMarkup < Struct.new(:project, :branch)
  BASE_URL = "http://inch-ci.org"
  IMAGE_FORMATS = [:png, :svg]
  DEFAULT_IMAGE_FORMAT = IMAGE_FORMATS.first

  def each(format = DEFAULT_IMAGE_FORMAT, &block)
    format_map(format).each(&block)
  end

  def image_formats
    IMAGE_FORMATS
  end

  def image_path(format = DEFAULT_IMAGE_FORMAT)
    "#{page_path}.#{format}?branch=#{branch.name}"
  end

  def image_url(format = DEFAULT_IMAGE_FORMAT)
    "#{BASE_URL}#{image_path(format)}"
  end

  private

  def format_map(format)
    image = image_url(format)
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
