require 'inch_ci/action'

module Action
  module Build
    class Show
      include InchCI::Action

      exposes :build, :filename, :dump

      def initialize(params, load_dump: false)
        if uid = params[:id]
          @build = BuildPresenter.new(InchCI::Store::FindBuild.call(uid))
          load_dump_if_present if load_dump
        end
      end

      private

      def load_dump_if_present
        @filename = Rails.root.join('dumps', 'builds', "build-#{@build.id}.json")
        @dump = File.read(@filename) if File.exist?(@filename)
      end
    end
  end
end
