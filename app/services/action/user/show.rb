require 'inch_ci/action'

module Action
  module User
    class Show
      include InchCI::Action

      exposes :user, :projects

      def initialize(params)
        if user = find_user(params)
          @user = UserPresenter.new(user)
          @projects = find_projects(@user).map { |p| ProjectPresenter.new(p) }
        else
          raise "Not found: #{params}"
        end
      end

      private

      def find_user(params)
        InchCI::Store::FindUser.call(params[:service], params[:user])
      end

      def find_projects(user)
        InchCI::Store::FindAllProjects.call(user)
      end
    end
  end
end
