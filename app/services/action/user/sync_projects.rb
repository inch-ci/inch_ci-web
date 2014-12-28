require 'inch_ci/action'

module Action
  module User
    class SyncProjects
      include InchCI::Action

      exposes :user, :projects

      def initialize(current_user, params)
        @user = UserPresenter.new(current_user)
        @projects = retrieve_projects(current_user).map { |p| ProjectPresenter.new(p) }
      end

      private

      def find_user(params)
        InchCI::Store::FindUser.call(params[:service], params[:user])
      end

      def retrieve_projects(user)
        InchCI::Worker::User::UpdateProjects.new.perform(user.id)
        InchCI::Store::FindAllProjects.call(user)
      end
    end
  end
end
