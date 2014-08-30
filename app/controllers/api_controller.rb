require 'inch'
require 'inch/cli'
require 'inch/utils/ui'
require 'inch/utils/buffered_ui'

class ApiController < ApplicationController
  protect_from_forgery with: :null_session

  def cli
    dump = dump_to_temp_file
    args = cli_args(dump) + [{:ui => buffered_ui}]
    command = ::Inch::CLI::Command::Suggest.run(*args)
    render :text => buffered_ui.buffer
  ensure
    dump.unlink unless dump.nil?
  end

  private

  def buffered_ui
    @buffered_io ||= ::Inch::Utils::BufferedUI.new
  end

  def cli_args(dump)
    ["--language=#{language_from_params}", "--read-from-dump=#{dump.path}"]
  end

  def dump_to_temp_file
    file = Tempfile.new('foo')
    file.write JSON[params]
    file.close
    file
  end

  def language_from_params
    :elixir
  end
end
