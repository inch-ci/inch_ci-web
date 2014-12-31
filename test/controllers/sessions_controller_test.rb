require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  setup do
    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:github]
  end

  test "should get :create" do
    skip # this fails since we do not yet have mocked the /following API call
    assert_difference(%w(User.count), 0) do
      assert_nil session[:user_id]
      get :create, :provider => 'github'
      refute_nil session[:user_id]
      assert_response :redirect
    end
  end

  test "should get :destroy" do
    with_login do |current_user|
      refute_nil session[:user_id]
      get :destroy
      assert_nil session[:user_id]
      assert_response :redirect
    end
  end
end
