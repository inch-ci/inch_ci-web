require 'inch_ci/action'

module Action
  module User
    class SyncProjects
      include InchCI::Action

      DEFAULT_TAB = Action::User::Show::DEFAULT_TAB

      exposes :user, :projects, :languages, :active_tab

      def initialize(current_user, params)
        @user = UserPresenter.new(current_user)
        @languages = Action::User::Show::LANGUAGES
        @projects = retrieve_projects(current_user).map { |p| ProjectPresenter.new(p) }
        @active_tab = params[:tab] || DEFAULT_TAB
      end

      private

      def find_user(params)
        InchCI::Store::FindUser.call(params[:service], params[:user])
      end

      def retrieve_projects(user)
        InchCI::Worker::User::UpdateProjects.new.perform(user.id)
        InchCI::Store::FindAllProjects.call(user).select(&:name)
      end
    end
  end
end
