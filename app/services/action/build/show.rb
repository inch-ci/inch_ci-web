require 'inch_ci/action'

module Action
  module Build
    class Show
      include InchCI::Action

      exposes :build

      def initialize(params)
        if uid = params[:id]
          @build = BuildPresenter.new(InchCI::Store::FindBuild.call(uid))
        end
      end
    end
  end
end
