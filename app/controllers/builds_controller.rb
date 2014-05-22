require 'inch_ci/controller'

class BuildsController < ApplicationController
  include InchCI::Controller

  layout 'page'

  def index
    view = Action::BuildHistory.new(params)
    expose view
  end
end
