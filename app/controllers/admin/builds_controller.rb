require 'inch_ci/controller'

class Admin::BuildsController < ApplicationController
  include InchCI::Controller

  layout 'admin'

  def index
    view = Action::BuildHistory.new(params)
    expose view
  end
end
