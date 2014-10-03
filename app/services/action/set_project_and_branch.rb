require 'inch_ci/action'

module Action
  module SetProjectAndBranch
    def set_project_and_branch(params)
      finder = InchCI::Action::FindProjectAndBranch.call(params)
      unless finder.project.nil?
        @project = ProjectPresenter.new(finder.project)
        @branch = finder.branch
      end
    end
  end
end
