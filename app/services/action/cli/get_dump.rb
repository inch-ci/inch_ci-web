require 'inch_ci/action'

module Action
  module CLI
    class GetDump
      include InchCI::Action

      exposes :filename, :json, :out

      def initialize(params)
        if @filename = params[:filename]
          @json = File.read( filename_from_params(@filename, :json) )
          @out  = terminal File.read( filename_from_params(@filename, :out) )
        end
      end

      private

      def filename_from_params(basename, ext)
        filename = File.join(dump_dir, basename.gsub(/[\.\~]/, '') + '.' + ext.to_s)
        filename if File.exists?(filename)
      end

      def dump_dir
        Rails.root.join('dumps', 'cli').to_s
      end

      def terminal(str)
        str.uncolored.strip
      end
    end
  end
end
