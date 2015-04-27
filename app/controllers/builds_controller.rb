require 'inch_ci/controller'

class BuildsController < ApplicationController
  include InchCI::Controller

  layout 'application'

  def index
    view = Action::BuildHistory.new(params)
    expose view
  end

  def history_show
    view = Action::Build::Show.new(params, load_diff: true)
    expose view
  end

  def show
    view = Action::Build::Show.new(params)
    expose view
    render :json => @build
  end
end
