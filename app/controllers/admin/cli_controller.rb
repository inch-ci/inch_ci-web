require 'inch_ci/controller'

class Admin::CliController < ApplicationController
  include InchCI::Controller

  layout 'admin'

  def index
    expose Action::CLI::ListDumps.new(params)
    expose Action::CLI::GetDump.new(params)
  end
end
