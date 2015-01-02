require 'inch_ci/controller'

class Admin::UsersController < ApplicationController
  include InchCI::Controller

  layout 'admin'

  def index
    @users = sort_collection(User)
    @languages = %w(Ruby Elixir Javascript)
  end

  private

  def sort_collection(arel)
    arel.order('created_at DESC')
  end
end
