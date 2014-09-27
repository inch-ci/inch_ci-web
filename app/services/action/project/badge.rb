require 'inch_ci/action'

module Action
  module Project
    class Badge
      include InchCI::Action
      include Action::SetProjectAndBranch

      exposes :project, :branch, :badge_filename, :content_type

      def initialize(params)
        set_project_and_branch(params)
        if !@project
          create_project_and_branch(params)
          if @project && @branch
            create_empty_badge
            enqueue_build
          end
        end
        if @project && @branch
          @badge = InchCI::BadgeRequest.new(@project.service_name, @project.user_name, @project.repo_name, @branch.name)
          format = params[:format].to_s
          style = params[:style]
          @badge_filename = @badge.local_filename(format, style)
          @content_type = content_types[format]
        end
      end

      def success?
        !@badge.nil?
      end

      private

      TRIGGER = 'manual'
      ORIGIN  = :badge_request

      def content_types
        {
          'png' => 'image/png',
          'svg' => 'image/svg+xml'
        }
      end

      def create_empty_badge
        InchCI::Badge.create(@project, @branch, [0,0,0,0])
      end

      def create_project_and_branch(url_or_params, _branch_name = nil)
        branch_name = url_or_params.is_a?(Hash) ? url_or_params[:branch] : nil
        branch_name ||= _branch_name
        if @branch = InchCI::Action::EnsureProjectAndBranch.call(url_or_params, branch_name, ORIGIN)
          @project = @branch.project
          @branch
        end
      end

      def enqueue_build
        InchCI::Worker::Project::Build.enqueue(@project.repo_url, @branch.name, nil, TRIGGER)
      end
    end
  end
end
