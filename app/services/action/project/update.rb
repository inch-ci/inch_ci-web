require 'inch_ci/action'

module Action
  module Project
    class Update
      include InchCI::Action
      include Action::SetProjectAndBranch

      exposes :project, :branch

      def initialize(current_user, params)
        set_project_and_branch(params)
        if current_user && @project.user_name == current_user.user_name
          @project = @project.to_model
          update_project(params[:project])
        end
      end

      def success?
        @project.valid?
      end

      private

      def update_project(attributes)
        @project.language = attributes[:language]
        InchCI::Store::SaveProject.call(@project)
      end
    end
  end
end
