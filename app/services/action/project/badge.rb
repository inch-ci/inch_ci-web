require 'inch_ci/action'

module Action
  module Project
    class Badge
      include InchCI::Action
      include Action::FindProjectAndBranch

      exposes :project, :branch, :filename

      def initialize(params)
        @project = find_project(params)
        @branch = find_branch(@project, params)
        if @project && @branch
          @badge = InchCI::BadgeRequest.new(@project.service_name, @project.user_name, @project.repo_name, @branch.name)
        end
      end

      def badge_filename
        @badge && @badge.local_filename
      end

      def success?
        !@badge.nil?
      end
    end
  end
end
