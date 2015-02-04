require 'inch_ci/repo_url'
require 'inch_ci/worker/project/build/calculate_diff'
require 'inch_ci/worker/project/build/generate_badge'

module InchCI
  module Worker
    module Project
      module Build
        class SaveBuildData
          DUPLICATE_STATUS = 'duplicate'

          def self.call(*args)
            new(*args)
          end

          # @param build_data [Hash] a Hash built from the 'build:' section
          #   of the worker output
          def initialize(build, build_data)
            @build = build
            @build_data = BuildData.new(build_data)

            Store.transaction do
              branch = ensure_project_and_branch_exist
              if @build_data.success?
                handle_successful_build(branch)
              else
                handle_failed_build(branch)
              end
            end
          end

          private

          def add_revision(branch, build_data, objects)
            revision = Store::CreateRevision.call(branch, build_data.revision_uid, build_data.tag_uid,
              build_data.revision_message, build_data.revision_author_name, build_data.revision_author_email,
                build_data.badge_in_readme?, build_data.revision_authored_at)
            create_objects_in_revision(revision, objects)
            revision
          end

          def allow_revision_rewrite?
            false #@build.trigger == 'travis'
          end

          def create_objects_in_revision(revision, objects)
            objects.each do |attributes|
              Store::CreateCodeObject.call(revision, attributes)
            end
          end

          def ensure_project_and_branch_exist
            info = RepoURL.new(@build_data.repo_url)
            project_uid = info.project_uid
            branch_name = @build_data.branch_name

            project = Store::FindProject.call(project_uid) ||
              Store::CreateProject.call(project_uid, @build_data.repo_url)

            Store::FindBranch.call(project, branch_name) ||
              Store::CreateBranch.call(project, branch_name)
          end

          def generate_badge(project, branch, revision)
            code_objects = Store::FindCodeObjects.call(revision)
            GenerateBadge.call(project, branch, code_objects)
          end

          def update_badge_information(project, branch, revision)
            return unless branch == project.default_branch

            relevant_code_objects = InchCI::Store::FindRelevantCodeObjects.call(revision)
            undocumented_code_objects = relevant_code_objects.select { |code_object| code_object.grade == 'U' }

            project.badge_generated = true
            project.badge_in_readme = revision.badge_in_readme
            if relevant_code_objects.size > 0
              project.badge_filled_in_percent = 100 - (undocumented_code_objects.size / relevant_code_objects.size.to_f * 100).to_i
            end

            if project.badge_in_readme_added_at.nil? && revision.badge_in_readme
              project.badge_in_readme_added_at = revision.created_at
            end
            if project.badge_in_readme_added_at && !revision.badge_in_readme &&
                                    project.badge_in_readme_removed_at.nil?
              project.badge_in_readme_removed_at = revision.created_at
            end

            Store::SaveProject.call(project)
          end

          def handle_failed_build(branch)
            Store::UpdateFinishedBuild.call(@build, nil, @build_data)
          end

          def handle_successful_build(branch)
            revision = Store::FindRevision.call(branch, @build_data.revision_uid)
            if revision
              if allow_revision_rewrite?
                rewrite_revision(revision, @build_data.objects)
              else
                @build_data.status = DUPLICATE_STATUS
              end
            else
              revision = add_revision(branch, @build_data, @build_data.objects)
              if @build_data.latest_revision?
                before_revision = Store::FindLatestRevision.call(branch)
                Store::UpdateLatestRevision.call(branch, revision)
                diff = CalculateDiff.call(before_revision, revision)
                Store::CreateRevisionDiff.call(branch, before_revision, revision, diff)
              end
            end
            generate_badge(branch.project, branch, revision)
            update_badge_information(branch.project, branch, revision)
            Store::UpdateFinishedBuild.call(@build, revision, @build_data)
          end

          def rewrite_revision(revision, objects)
            create_objects_in_revision(revision, objects)
          end

          class BuildData
            attr_reader :repo_url, :branch_name
            attr_reader :revision_uid, :tag_uid, :revision_message
            attr_reader :started_at, :finished_at, :trigger, :objects
            attr_reader :revision_author_name, :revision_author_email, :revision_authored_at
            attr_reader :inch_version
            attr_accessor :status

            def initialize(data)
              @data = data
              @status = @data['status']
              @trigger = @data['trigger']
              @repo_url = @data['repo_url']
              @branch_name = @data['branch_name']
              @revision_uid = @data['revision_uid']
              @revision_message = @data['revision_message']
              @revision_author_name = @data['revision_author_name']
              @revision_author_email = @data['revision_author_email']
              @revision_authored_at = @data['revision_authored_at']
              @tag_uid = @data['tag']
              @started_at = @data['started_at']
              @finished_at = @data['finished_at']
              @objects = @data['objects']
              @inch_version = data['inch_version']
            end

            def badge_in_readme?
              @data['badge_in_readme']
            end

            # Returns true if the currently built revision should be treated as
            # the latest revision in the branch.
            def latest_revision?
              @data['latest_revision']
            end

            def project_uid
              "#{@data['service_name']}:#{@data['user_name']}/#{@data['repo_name']}"
            end

            def success?
              status == 'success'
            end
          end
        end
      end
    end
  end
end
