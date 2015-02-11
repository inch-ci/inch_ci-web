require 'inch_ci/action'

module Action
  module User
    class Welcome
      include InchCI::Action

      LIMIT = 9

      exposes :user, :followed_projects

      def initialize(user)
        @user = user
        @followed_projects = find_projects(user).select(&:badge?)
        count = @followed_projects.size
        if count < LIMIT
          @followed_projects.concat featured_projects(LIMIT-count)
        else
          @followed_projects = @followed_projects[0...LIMIT]
        end
      end

      private

      def find_projects(user)
        sql = (['uid LIKE ?'] * user.follows.size).join(' OR ')
        uids = user.follows.map { |name| "github:#{name}/%" }
        present ::Project.includes(:default_branch)
                        .where(sql, *uids)
      end

      def featured_projects(limit)
        present ::Project.includes(:default_branch)
                  .where(:id => featured_projects_uids(limit, :ruby))
      end

      def featured_projects_uids(limit, language)
        FEATURED_PROJECT_UIDS[language][0...limit]
      end

      def present(projects)
        projects.map { |p| ProjectPresenter.new(p) }
      end
    end
  end
end
