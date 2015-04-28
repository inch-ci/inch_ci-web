require 'inch_ci/action'

module Action
  module Project
    class Update
      include InchCI::Action
      include Action::SetProjectAndBranch

      exposes :project, :branch

      # allow if user owns project or user is in project's org
      def self.can_edit?(current_user, project)
        project.user_name.downcase == current_user.user_name.downcase ||
          current_user.organizations.map(&:downcase)
            .include?(project.user_name.downcase)
      end

      def initialize(current_user, params)
        set_project_and_branch(params)
        if current_user && self.class.can_edit?(current_user, @project)
          @project = @project.to_model
          update_project(params[:project])
        end
      end

      def success?
        @project.valid?
      end

      private

      def update_project(attributes)
        @project.documentation_url = attributes[:documentation_url]
        @project.language = attributes[:language]
        InchCI::Store::SaveProject.call(@project)
      end
    end
  end
end
