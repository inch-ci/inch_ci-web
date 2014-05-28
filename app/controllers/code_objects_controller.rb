require 'inch_ci/controller'

class CodeObjectsController < ApplicationController
  include InchCI::Controller

  def show
    view = Action::CodeObject::Show.new(params)
    expose view
    if view.code_object.nil?
      render :text => "CodeObject not found.", :layout => true, :status => 404
    end
  end
end
