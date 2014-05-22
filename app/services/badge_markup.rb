class BadgeMarkup < Struct.new(:project, :branch)
  def each(&block)
    format_map.each(&block)
  end

  def image_path(format = :png)
    "#{page_path}.#{format}?branch=#{branch.name}"
  end

  def image_url(format = :png)
    "#{BASE_URL}#{image_path(format)}"
  end

  private

  BASE_URL = "http://inch-pages.github.io"

  def format_map
    image = image_url
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
