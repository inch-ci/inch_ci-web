module InchCI
  module BadgeMethods
    IMAGE_FORMATS = %w(png svg)
    IMAGE_STYLES = %w(default flat flat-square)
    DEFAULT_IMAGE_FORMAT = IMAGE_FORMATS.first
    DEFAULT_IMAGE_STYLE = IMAGE_STYLES.first

    def self.included(base)
      base.extend ClassMethods
    end

    def filename(format = DEFAULT_IMAGE_FORMAT, style = DEFAULT_IMAGE_STYLE)
      unless IMAGE_STYLES.include?(style)
        style = DEFAULT_IMAGE_STYLE
      end
      File.join(*project_triple, "#{branch_name}.#{style}.#{format}")
    end

    def local_filename(format = DEFAULT_IMAGE_FORMAT, style = DEFAULT_IMAGE_STYLE)
      File.join(Rails.root, public_dir, filename(format, style))
    end

    private

    def public_dir
      Rails.env.test? ? 'tmp' : 'public'
    end

    def project_triple
      raise "Implement me"
    end

    module ClassMethods
      def each_image_combination
        IMAGE_FORMATS.each do |format|
          IMAGE_STYLES.each do |style|
            yield format, style
          end
        end
      end
    end
  end

  class Badge < Struct.new(:project, :branch)
    include BadgeMethods

    def self.create(project, branch, counts)
      badge = new(project, branch)
      each_image_combination do |format, style|
        filename = badge.local_filename(format, style)
        FileUtils.mkdir_p File.dirname(filename)
        Inch::Badge::Image.create(filename, counts, {:style => style})
      end
    end

    private

    def branch_name
      branch.name
    end

    def project_triple
      [project.service_name, project.user_name, project.repo_name]
    end
  end

  class BadgeRequest < Struct.new(:service_name, :user_name, :repo_name, :branch_name)
    include BadgeMethods

    def project_triple
      [service_name, user_name, repo_name]
    end
  end
end
