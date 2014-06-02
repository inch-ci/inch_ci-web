require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

describe ::InchCI::Badge do
  fixtures :all

  let(:described_class) { ::InchCI::Badge }

  it "should only create code objects when they change" do
    project = Project.find_by_uid("github:rrrene/sparkr")
    branch = project.default_branch
    counts = [0,1,2,3]
    described_class.create(project, branch, counts)
    base = File.join(Rails.root, "tmp", "github", "rrrene", "sparkr")
    %w(png svg).each do |image_format|
      assert File.exist?(File.join(base, "master.#{image_format}"))
    end
  end
end
