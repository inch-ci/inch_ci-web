require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

describe ::InchCI::Worker::Project::BuildJSON do
  let(:described_class) { ::InchCI::Worker::Project::BuildJSON }
  let(:filename) { File.expand_path(File.dirname(__FILE__) + '/../../../fixtures/dumps/elixir/inch_ex.json') }

  it "should work using .enqueue" do
    changes = %w(Build.count Revision.count CodeObject.count CodeObjectRole.count)
    assert_positive_difference(changes) do
      described_class.enqueue(filename)
    end
    build = Build.last
    refute_nil build.inch_version
    refute_empty build.inch_version
  end
end
