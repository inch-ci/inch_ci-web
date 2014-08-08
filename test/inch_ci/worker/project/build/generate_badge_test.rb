require File.expand_path(File.dirname(__FILE__) + '/../../../../test_helper')

describe ::InchCI::Worker::Project::Build::GenerateBadge do
  fixtures :all

  let(:described_class) { ::InchCI::Worker::Project::Build::GenerateBadge }

  it "should only create code objects when they change" do
    project = Project.find_by_uid("github:rrrene/sparkr")
    branch = project.default_branch
    code_objects = branch.latest_revision.code_objects
    described_class.new(project, branch, code_objects)
    base = File.join(Rails.root, "tmp", "github", "rrrene", "sparkr")
    assert_badge(base)
  end
end
