require 'inch_ci/controller'

class UsersController < ApplicationController
  include InchCI::Controller

  before_action :require_login

  def show
    action = Action::User::Show.new(params)
    expose action
  end
end
