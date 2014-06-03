require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

describe ::InchCI::RepoURL do
  fixtures :all

  let(:described_class) { ::InchCI::RepoURL }

  it "should return project_uid for GitHub web-url" do
    info = described_class.new('https://github.com/rrrene/inch')
    assert_equal 'github:rrrene/inch', info.project_uid
  end

  it "should return project_uid for slightly malformed GitHub web-url" do
    info = described_class.new('https://github.com/rrrene/inch/')
    assert_equal 'github:rrrene/inch', info.project_uid
  end

  it "should return project_uid for slightly malformed GitHub web repo-url" do
    info = described_class.new('https://github.com/rrrene/inch.git')
    assert_equal 'github:rrrene/inch', info.project_uid
  end
end
