module InchCI
  module BadgeMethods
    FORMATS = %w(png svg)
    DEFAULT_FORMAT = FORMATS.first

    def filename(format = DEFAULT_FORMAT)
      File.join(*project_triple, "#{branch_name}.#{format}")
    end

    def local_filename(format = DEFAULT_FORMAT)
      File.join(Rails.root, public_dir, filename)
    end

    private

    def public_dir
      Rails.env.test? ? 'tmp' : 'public'
    end

    def project_triple
      raise "Implement me"
    end
  end

  class Badge < Struct.new(:project, :branch)
    include BadgeMethods

    def self.create(project, branch, counts)
      badge = new(project, branch)
      FORMATS.each do |format|
        filename = badge.local_filename(format)
        FileUtils.mkdir_p File.dirname(filename)
        Inch::Badge::Image.create(filename, counts)
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
