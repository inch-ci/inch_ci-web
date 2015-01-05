require 'inch_ci/controller'

class Admin::BuildsController < ApplicationController
  include InchCI::Controller

  layout 'admin'

  def index
    view = Action::BuildHistory.new(params)
    expose view
  end

  def show
    view = Action::Build::Show.new(params, load_dump: true)
    expose view
  end
end
