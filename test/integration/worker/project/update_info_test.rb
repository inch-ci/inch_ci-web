require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

describe ::InchCI::Worker::Project::UpdateInfo do
  fixtures :all

  let(:described_class) { ::InchCI::Worker::Project::UpdateInfo }
  let(:project_uid) { "github:rrrene/sparkr" }

  it "should work using .enqueue" do
    described_class.enqueue(project_uid)
  end
end
