require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

require 'inch_ci/project_uid'

describe ::InchCI::ProjectUID do
  fixtures :all

  let(:described_class) { ::InchCI::ProjectUID }

  it "should return project_uid for params" do
    params = {:service => 'github', :user => 'user_name', :repo => 'with-numbers-1232'}
    info = described_class.new(params)
    assert_equal 'github:user_name/with-numbers-1232', info.project_uid
    assert_equal 'https://github.com/user_name/with-numbers-1232.git', info.repo_url
  end

  it "should not return project_uid for malformed params" do
    params = {:service => 'github', :user_name => 'user_name'}
    info = described_class.new(params)
    assert_nil info.project_uid
    assert_nil info.repo_url
  end

  it "should return project_uid for a uid" do
    info = described_class.new('github:user_name/with-numbers-1232')
    assert_equal 'github:user_name/with-numbers-1232', info.project_uid
    assert_equal 'https://github.com/user_name/with-numbers-1232.git', info.repo_url
  end

  it "should not return project_uid for malformed uid" do
    info = described_class.new('github:user_name/')
    assert_nil info.project_uid
    assert_nil info.repo_url
  end
end
