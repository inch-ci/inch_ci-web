require 'inch_ci/action'

module Action
  module CLI
    class ListDumps
      include InchCI::Action

      LANGUAGES = %w(elixir nodejs)

      exposes :languages, :language, :filenames, :dates

      def initialize(params)
        @languages = LANGUAGES

        if @language = params[:language]
          glob = File.join(dump_dir, '**/*.json')
          @filenames = filter_by_language(basenames_by_glob(glob))
          @dates = {}
          @filenames.each do |filename|
            date = filename =~ /\/(\d+)\// && $1
            unless date.nil?
              @dates[date] ||= []
              @dates[date] << filename
            end
          end
        end
      end

      private

      def dump_dir
        Rails.root.join('dumps', 'cli').to_s
      end

      def basenames_by_glob(glob)
        Dir[glob].sort.reverse.map do |f|
          f.gsub(dump_dir+'/', '').gsub(/\.json$/, '')
        end
      end

      def filter_by_language(filenames)
        filenames.select do |f|
          f.starts_with?(@language)
        end
      end
    end
  end
end
