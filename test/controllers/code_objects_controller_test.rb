require 'test_helper'

class CodeObjectsControllerTest < ActionController::TestCase
  fixtures :all

  test "should get :show with existing revision" do
    rev = '8849af2b7ad96c6aa650a6fd5490ef83629faf2a'
    short_rev = rev[0..6]
    [rev, short_rev].each do |revision_uid|
      %w(html js).each do |format|
        params = {
          :service => 'github',
          :user => 'rrrene',
          :repo => 'sparkr',
          :branch => 'master',
          :revision => revision_uid,
          :code_object => '1',
          :format => format
        }
        get :show, params
        assert_response :success
      end
    end
  end
end
