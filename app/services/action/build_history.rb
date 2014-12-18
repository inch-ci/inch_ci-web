require 'inch_ci/action'

module Action
  class BuildHistory
    include InchCI::Action
    include Action::SetProjectAndBranch

    exposes :project, :branch, :builds
    exposes :running_builds, :scheduled_builds, :completed_builds

    def initialize(params)
      @language = params[:language]
      set_project_and_branch(params)
      set_builds
    end

    private

    def set_builds
      @builds = find_builds.map do |build|
          BuildPresenter.new(build)
        end
      @scheduled_builds = @builds.select { |b| b.status == 'created' }
      @running_builds = @builds.select { |b| b.status == 'running' }
      @completed_builds = @builds.select { |b| !%w(created running).include?(b.status) }
    end

    def find_builds
      filter_collection(collection)
    end

    def collection
      if @project.nil?
        InchCI::Store::FindBuilds.call()
      else
        InchCI::Store::FindBuildsInProject.call(@project)
      end
    end

    def filter_collection(arel)
      if @language
        arel = arel.select { |b| b.branch.project.language.to_s.downcase ==  @language.downcase}
      end
      arel
    end
  end
end
