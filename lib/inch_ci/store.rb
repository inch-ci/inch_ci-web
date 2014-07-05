module InchCI
  # ActiveRecordStore provides a thin layer on top of ActiveRecord so we do not
  # need to use it's API in our own code.
  module Store
    FindProject = -> (uid) { Project.find_by_uid(uid) }
    FindAllProjects = -> () { Project.all }
    CreateProject = -> (uid, repo_url) { Project.create!(:uid => uid, :repo_url => repo_url) }
    SaveProject = -> (project) { project.save! }
    UpdateDefaultBranch = -> (project, branch) { project.update_attribute(:default_branch, branch) }

    # this does not belong here
    EnsureProject = -> (url) {
      info = RepoURL.new(url)
      if info.project_uid
        Store::FindProject.call(info.project_uid) ||
          Store::CreateProject.call(info.project_uid, info.url)
      end
    }
    # this does not belong here
    EnsureProjectAndBranch = -> (url, branch_name) {
      project = Store::EnsureProject.call(url)

      Store::FindBranch.call(project, branch_name) ||
        Store::CreateBranch.call(project, branch_name)
    }

    FindBranch = -> (project, name) { project.branches.where(:name => name).first }
    CreateBranch = -> (project, name) { project.branches.create!(:name => name) }
    FindDefaultBranch = -> (project) { project.default_branch || project.branches.first }

    FindRevision = -> (branch, uid) { branch.revisions.where('uid LIKE ?', "#{uid}%").first }
    CreateRevision = -> (branch, uid, tag_uid, message, author_name, author_email, badge_in_readme, authored_at) {
      attributes = {
        :uid => uid,
        :tag_uid => tag_uid,
        :badge_in_readme => badge_in_readme,
        :message => message,
        :author_name => author_name,
        :author_email => author_email,
        :authored_at => authored_at,
      }
      branch.revisions.create!(attributes)
    }

    FindLatestRevision = -> (branch) { branch.latest_revision }
    UpdateLatestRevision = -> (branch, revision) { branch.update_attribute(:latest_revision, revision) }

    class CreateRevisionDiff
      attr_reader :revision_diff

      def self.call(*args)
        new(*args).revision_diff
      end

      def initialize(branch, before_revision, after_revision, diff)
        @revision_diff = create_revision_diff(branch, before_revision, after_revision)
        diff.comparisons.each do |comparer|
          unless comparer.unchanged?
            create_code_object_diff(comparer)
          end
        end
      end

      private

      def create_revision_diff(branch, before_revision, after_revision)
        attributes = {
          :before_revision => before_revision,
          :after_revision => after_revision
        }
        branch.revision_diffs.create!(attributes)
      end

      def create_code_object_diff(comparer)
        attributes = {
          :before_object => comparer.before,
          :after_object => comparer.after,
          :change => comparer.change
        }
        revision_diff.code_object_diffs.create!(attributes)
      end
    end

    FindBuild = -> (id) { Build.find(id) }
    FindBuilds = -> (count = 200) { Build.order('id DESC').limit(count).includes(:revision).includes(:branch).includes(:project) }
    FindBuildsInProject = -> (project) { project.builds }
    FindLatestBuildInProject = -> (project) { project.builds.order('id DESC').first }

    CreateBuild = -> (branch, trigger, status = 'created') do
        attributes = {
          :status => status,
          :trigger => trigger,
          :number => branch.project.builds.count + 1
        }
        branch.builds.create!(attributes)
      end

    UpdateFinishedBuild = -> (build, revision, build_data) do
        attributes = {
          :revision => revision,
          :status => build_data.status,
          :finished_at => Time.now
        }
        build.update_attributes!(attributes)
      end

    UpdateBuildStatus = -> (build, status, started_at) do
      attributes = {
        :status => status,
        :started_at => started_at
      }
      build.update_attributes!(attributes)
    end


    FindCodeObject = -> (id) { CodeObject.includes(:code_object_roles).find(id) }
    FindCodeObjects = -> (revision) { revision.code_objects }
    FindRelevantCodeObjects = -> (revision) do
      revision.code_objects.select { |object| object.priority >= Config::MIN_RELEVANT_PRIORITY }
    end

    class BuildCodeObject
      attr_reader :code_object

      def self.call(*args)
        new(*args).code_object
      end

      def initialize(revision, attributes)
        @code_object = build_code_object(revision, attributes)
      end

      private

      def build_code_object(revision, attributes)
        roles = attributes.delete('roles') || []
        code_object = CodeObject.new(attributes)
        code_object.project = revision.branch.project
        roles.each do |attributes|
          build_code_object_role(code_object, attributes)
        end
        code_object
      end

      def build_code_object_role(code_object, attributes)
        name = attributes.delete('name')
        role_name = ensure_role_name(name)
        attributes.merge!(:code_object_role_name => role_name)
        code_object.code_object_roles.build(attributes)
      end

      def ensure_role_name(name)
        CodeObjectRoleName.find_by_name(name) ||
          CodeObjectRoleName.create(:name => name)
      end
    end

    class CreateCodeObject
      attr_reader :code_object

      def self.call(*args)
        new(*args).code_object
      end

      def initialize(revision, attributes)
        @code_object = find_or_create_code_object(revision, attributes)
        create_code_object_reference(revision)
      end

      private

      def create_code_object_reference(revision)
        revision.code_object_references.create!(:code_object => @code_object)
      end

      def find_or_create_code_object(revision, attributes)
        code_object = BuildCodeObject.call(revision, attributes)
        digest = DigestCodeObject.call(code_object)
        if object = find_code_object(code_object.project, digest)
          object
        else
          code_object.digest = digest
          code_object.save!
          code_object
        end
      end

      def find_code_object(project, digest)
        CodeObject.where(:project_id => project.id, :digest => digest).first
      end
    end

    class DigestCodeObject
      attr_reader :digest

      def self.call(*args)
        new(*args).digest
      end

      def initialize(code_object)
        hash = attributes_for_code_object(code_object)
        @digest = Digest::SHA1.base64digest(hash.to_yaml)
      end

      def attributes_for_code_object(object)
        attributes = data_attributes(object)
        attributes['roles'] = object.code_object_roles.map do |role|
          attributes_for_code_object_role(role)
        end
        attributes
      end

      def attributes_for_code_object_role(role)
        attributes = data_attributes(role)
        attributes['name'] = role.code_object_role_name.name
        attributes
      end

      # Returns all attributes except
      # id, digest, created_at, updated_at and all attributes ending in *_id
      #
      def data_attributes(object)
        object.attributes.delete_if do |k,v|
          k =~ /^(created_at|updated_at|digest|id)$/ || k =~ /_id$/
        end
      end
    end

    def self.transaction(&block)
      ActiveRecord::Base.transaction(&block)
    end
  end
end
