require 'inch_ci/controller'

class BuildsController < ApplicationController
  include InchCI::Controller

  layout 'application'

  def index
    view = Action::BuildHistory.new(params)
    expose view
  end

  def dashboard
    view = Action::Build::Dashboard.new(params)
    expose view
  end

  def show
    view = Action::Build::Show.new(params)
    expose view
    render :json => @build
  end
end
