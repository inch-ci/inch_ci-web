require 'inch_ci/action'

module Action
  module CodeObject
    class Show
      include InchCI::Action
      include Action::SetProjectAndBranch

      exposes :project, :branch, :revision, :code_object

      def initialize(params)
        set_project_and_branch(params)
        @revision = find_revision(@branch, params)
        @code_object = find_code_object(params)
      end

      private

      def find_code_object(params)
        resource = InchCI::Store::FindCodeObject.call(params[:code_object])
        CodeObjectPresenter.new(resource)
      end

      def find_revision(branch, params)
        return if branch.nil?
        if revision_uid = params[:revision]
          InchCI::Store::FindRevision.call(@branch, revision_uid)
        else
          InchCI::Store::FindLatestRevision.call(@branch)
        end
      end
    end
  end
end
