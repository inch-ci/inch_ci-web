require 'inch_ci/action'

module Action
  module Build
    class Dashboard
      include InchCI::Action
      include Action::SetProjectAndBranch

      exposes :today_builds, :yesterday_builds, :other_builds

      def initialize(params)
        set_project_and_branch(params)
        @builds = find_builds.map do |build|
            BuildPresenter.new(build)
          end
        @today_builds = @builds.select { |b| b.finished_at && b.finished_at.midnight.utc == today }
        @yesterday_builds = @builds.select { |b| b.finished_at && b.finished_at.midnight.utc == yesterday }
        @other_builds = @builds - @today_builds - @yesterday_builds
      end

      private

      def find_builds
        if @project.nil?
          InchCI::Store::FindBuilds.call()
        else
          InchCI::Store::FindBuildsInProject.call(@project)
        end
      end

      def today
        @today ||= Time.now.utc.midnight
      end

      def yesterday
        @yesterday ||= today - 1.day
      end

    end
  end
end
