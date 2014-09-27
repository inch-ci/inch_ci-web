require 'inch_ci/action'

module Action
  module SetProjectAndBranch
    def set_project_and_branch(params)
      finder = InchCI::Action::FindProjectAndBranch.call(params)
      @project = finder.project
      @branch = finder.branch
    end
  end
end
