require 'inch_ci/action'

module Action
  class BuildHistory
    include InchCI::Action
    include Action::FindProjectAndBranch

    exposes :project, :branch, :builds

    def initialize(params)
      @project = find_project(params)
      @branch = find_branch(@project, params)
      @builds = find_builds.map do |build|
          BuildPresenter.new(build)
        end
    end

    private

    def find_builds
      if @project.nil?
        InchCI::Store::FindBuilds.call()
      else
        InchCI::Store::FindBuildsInProject.call(@project)
      end
    end
  end
end
