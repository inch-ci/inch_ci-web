require 'inch'
require 'inch/cli'
require 'inch/utils/ui'
require 'inch/utils/buffered_ui'
require 'fileutils'

module Api
  class CliController < ApplicationController
    protect_from_forgery with: :null_session

    def hint
      render_text "> Greetings, Professor Falken.\n\n> _\n"
    end

    def run
      # let's ensure backwards compatibility
      params[:language] = 'javascript' if params[:language] == 'nodejs'

      if valid_params?
        dump = dump_request_to_file
        args = cli_args(dump) + [{:ui => buffered_ui}]
        command = ::Inch::CLI::CommandParser.run(*args)
        dump_output_to_file
        render_text buffered_ui.buffer
      else
        render_text "[ERROR] #{@param_errors}\n"
      end
    rescue SystemExit => e
      render_text buffered_ui.buffer
    end

    private

    def buffered_ui
      @buffered_io ||= ::Inch::Utils::BufferedUI.new
    end

    def cli_args(dump)
      args_from_params + ["--language=#{language_from_params}", "--read-from-dump=#{dump.path}"]
    end

    def dump_request_to_file
      write_file filename_with_extension(:json), JSON.pretty_generate(params)
    end

    def dump_output_to_file
      write_file filename_with_extension(:out), buffered_ui.buffer
    end

    def filename_with_extension(ext)
      dir = Rails.root.join('dumps', 'cli', language_from_params, Time.now.strftime('%Y%m%d'))
      File.join(dir, request.object_id.to_s + '.' + ext.to_s)
    end

    def args_from_params
      params[:args] || []
    end

    def command_from_args
      args_from_params.first
    end

    def language_from_params
      params[:language]
    end

    def render_text(text)
      render :text => text, :content_type => "text/plain"
    end

    def write_file(filename, contents)
      FileUtils.mkdir_p File.dirname(filename)
      file = File.new(filename, 'w')
      file.write contents
      file.close
      file
    end

    VERBOTEN_COMMANDS = %w(diff inspect console)
    def valid_params?
      if language_from_params.to_s.empty?
        @param_errors = "No language defined."
      end
      if VERBOTEN_COMMANDS.include?(command_from_args)
        @param_errors = "The '#{command_from_args}' command is not supported via API.\n\nIf you want to use it, you have to install Inch locally."
      end
      @param_errors.nil?
    end
  end
end
