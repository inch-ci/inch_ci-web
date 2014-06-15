require 'inch_ci/action'

module Action
  module SetProjectAndBranch
    def set_project_and_branch(params)
      finder = InchCI::Action::FindProjectAndBranch.call(params)
      @project = finder.project
      @branch = finder.branch
    end

    def create_project_and_branch(url_or_params, _branch_name = nil)
      branch_name = url_or_params.is_a?(Hash) ? url_or_params[:branch] : nil
      branch_name ||= _branch_name
      @branch = InchCI::Action::EnsureProjectAndBranch.call(url_or_params, branch_name)
      @project = @branch.project
      @branch
    end
  end
end
