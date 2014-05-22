require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

describe ::InchCI::Worker::Project::Build do
  let(:described_class) { ::InchCI::Worker::Project::Build }
  let(:repo_url) { "git@github.com:rrrene/repomen.git" }

  it "should work using .enqueue" do
    changes = %w(Build.count Revision.count CodeObject.count CodeObjectRole.count)
    assert_positive_difference(changes) do
      described_class.enqueue(repo_url)
    end
  end

  # this tests if we can use the async worker directly, utilizing its default
  # parameters, especially the non-existent preliminary build object
  it "should work using .perform_async" do
    changes = %w(Build.count Revision.count CodeObject.count CodeObjectRole.count)
    assert_positive_difference(changes) do
      described_class::ShellInvocation.perform_async(repo_url)
    end
  end
end
