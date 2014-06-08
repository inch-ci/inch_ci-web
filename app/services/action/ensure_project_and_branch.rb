require 'inch_ci/action'

module Action
  module EnsureProjectAndBranch
    def ensure_project_and_branch(project_url, branch_name)
      branch = InchCI::Store::EnsureProjectAndBranch.call(project_url, branch_name)
      project = branch.project
      update_project(project) if !project.default_branch
      branch
    end

    def update_project(project)
      worker = InchCI::Worker::Project::UpdateInfo.new
      worker.perform(project.uid)
    end
  end
end
