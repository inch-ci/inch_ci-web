require File.expand_path(File.dirname(__FILE__) + '/../../../../test_helper')

describe ::InchCI::Worker::Project::Build::HandleWorkerOutput do
  fixtures :builds

  let(:described_class) { ::InchCI::Worker::Project::Build::HandleWorkerOutput }
  let(:repo_url) { 'git@github.com:rrrene/sparkr.git' }
  let(:branch_name) { 'master' }
  let(:trigger) { 'manual' }
  let(:build) { Build.first }

  FakeSaveBuildData = -> (build, data) { }

  it 'should work with a valid build' do
    output = WorkerOutputMock.string(:codebase_3_objects)
    stderr = ''
    described_class.new(output, stderr, build, FakeSaveBuildData)
  end

  it 'should work with an empty output' do
    output = ''
    stderr = ''
    assert_raises RuntimeError do
      described_class.new(output, stderr, build, FakeSaveBuildData)
    end
  end
end
