require 'inch_ci/action'

module Action
  module Project
    class Badge
      include InchCI::Action
      include Action::SetProjectAndBranch

      exposes :project, :branch, :badge_filename, :content_type

      def initialize(params)
        set_project_and_branch(params)
        if @project && @branch
          @badge = InchCI::BadgeRequest.new(@project.service_name, @project.user_name, @project.repo_name, @branch.name)
          format = params[:format].to_s
          @badge_filename = @badge.local_filename(format)
          @content_type = content_types[format]
        end
      end

      def success?
        !@badge.nil?
      end

      private

      def content_types
        {
          'png' => "image/png",
          'svg' => "image/svg+xml"
        }
      end
    end
  end
end
