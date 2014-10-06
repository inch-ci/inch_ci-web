require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

describe ::Action::Project::Create do
  let(:described_class) { ::Action::Project::Create }
  let(:repo_url) { "https://github.com/rrrene/repomen.git" }
  let(:repo_nwo) { "rrrene/repomen" }
  let(:invalid_input) { "invalid_input" }
  let(:origin) { 'homepage' }

  it "should work with git URL" do
    params = {:repo_url => repo_url}
    action = described_class.new(params, origin)
    assert action.success?
    project = action.project
    assert project.valid?
    assert_equal repo_url, project.repo_url
    assert_equal origin, project.origin
  end

  it "should work with GitHub nwo" do
    params = {:repo_url => repo_nwo}
    action = described_class.new(params, origin)
    assert action.success?
    project = action.project
    assert project.valid?
    assert_equal repo_url, project.repo_url
    assert_equal origin, project.origin
  end


  it "should not work with mumbo jumbo" do
    params = {:repo_url => invalid_input}
    action = described_class.new(params, origin)
    refute action.success?
  end

  it "should not work with verboten origin" do
    params = {:repo_url => repo_url}
    action = described_class.new(params)
    project = action.project
    assert project.valid?
    assert_equal repo_url, project.repo_url
    refute_equal origin, project.origin
  end
end
