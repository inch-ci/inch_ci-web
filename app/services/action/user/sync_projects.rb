require 'inch_ci/action'

module Action
  module User
    class SyncProjects
      include InchCI::Action

      exposes :user, :projects

      def initialize(current_user, params)
        if user = find_user(params)
          @user = UserPresenter.new(user)
          @projects = retrieve_projects(@user).map { |p| ProjectPresenter.new(p) }
        else
          raise "Not found: #{params}"
        end
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
