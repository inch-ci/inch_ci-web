require 'inch_ci/action'

module Action
  class BuildHistory
    include InchCI::Action
    include Action::SetProjectAndBranch

    exposes :project, :branch, :builds
    exposes :running_builds, :scheduled_builds, :completed_builds

    def initialize(params)
      set_project_and_branch(params)
      @builds = find_builds.map do |build|
          BuildPresenter.new(build)
        end
      @scheduled_builds = @builds.select { |b| b.status == 'created' }
      @running_builds = @builds.select { |b| b.status == 'running' }
      @completed_builds = @builds.select { |b| !%w(created running).include?(b.status) }
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
