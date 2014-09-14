require File.expand_path(File.dirname(__FILE__) + '/../../../../test_helper')

describe ::InchCI::Worker::Project::Build::HandleWorkerOutput do
  fixtures :builds

  let(:described_class) { ::InchCI::Worker::Project::Build::HandleWorkerOutput }
  let(:repo_url) { 'https://github.com/rrrene/sparkr.git' }
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

  it 'should work with output littered with YARD warnings' do
    output = <<-STDOUT
[error]: NameError: uninitialized constant YARD::Handlers::Ruby::PrivateClassMethodHandler::NamespaceMissingError
[error]: Stack trace:
  /home/user/.rvm/gems/ruby-2.1.2@inch_ci/gems/yard-0.8.7.4/lib/yard/handlers/ruby/private_class_method_handler.rb:32:in `rescue in privatize_class_method'
  /home/user/.rvm/gems/ruby-2.1.2@inch_ci/gems/yard-0.8.7.4/lib/yard/handlers/ruby/private_class_method_handler.rb:25:in `privatize_class_method'
  /home/user/.rvm/gems/ruby-2.1.2@inch_ci/gems/yard-0.8.7.4/lib/yard/handlers/ruby/private_class_method_handler.rb:11:in `block (2 levels) in <class:PrivateClassMethodHandler>'
  /home/user/.rvm/gems/ruby-2.1.2@inch_ci/gems/yard-0.8.7.4/lib/yard/handlers/ruby/private_class_method_handler.rb:8:in `each'
  /home/user/.rvm/gems/ruby-2.1.2@inch_ci/gems/yard-0.8.7.4/lib/yard/handlers/ruby/private_class_method_handler.rb:8:in `block in <class:PrivateClassMethodHandler>'
  /home/user/.rvm/gems/ruby-2.1.2@inch_ci/gems/yard-0.8.7.4/lib/yard/handlers/processor.rb:114:in `block (2 levels) in process'

[warn]: YARD will recover from this error and continue to parse but you *may* have problems
[warn]: with your generated documentation. You should probably fix this.
[warn]: -
---
build:
  status: success
  repo_url: https://github.com/puppetlabs/puppet.git
  branch_name: master
  started_at: &1 2014-09-14 22:49:58.645222890 +02:00
  finished_at: *1
  latest_revision: true
  service_name: github
  user_name: puppetlabs
  repo_name: puppet
  badge_in_readme: true
  inch_version: 0.5.0.rc6
  revision_uid: ab15dc8812b22069d035116842b1cd0360671997
  revision_message: "(PUP-3144) Skip the openbsd service specs on windows"
  revision_author_name: Kylo Ginsberg
  revision_author_email: kylo@puppetlabs.com
  revision_authored_at: Fri Sep 12 17:34:17 2014 -0700
  objects: []
STDOUT
    stderr = ''
    described_class.new(output, stderr, build, FakeSaveBuildData)
  end
end
