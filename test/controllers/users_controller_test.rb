require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  UNAUTHORIZED = 401

  test "should get :init_projects" do
    with_login do |current_user|
      post :init_projects, :format => 'js'
      assert_response :success
    end
  end

  test "should get :sync_projects" do
    with_login do |current_user|
      assert_positive_difference(%w(Project.count Branch.count)) do
        post :sync_projects
        assert_response :redirect
      end
    end
  end

  #
  # SHOW
  #

  test "should not get :show" do
    get :show, :service => 'github', :user => 'rrrene'
    assert_response UNAUTHORIZED
  end

  test "should get :show" do
    with_login do |current_user|
      get :show, :service => 'github', :user => 'rrrene'
      assert_response :success
    end
  end

  #
  # WELCOME
  #

  test "should get :welcome" do
    with_login do |current_user|
      get :welcome
      assert_response :success
    end
  end

  test "should not get :welcome" do
    get :welcome
    assert_response UNAUTHORIZED
  end
end
