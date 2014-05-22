require File.expand_path(File.dirname(__FILE__) + '/../../../../test_helper')

describe ::InchCI::Worker::Project::Build::SaveBuildData do
  fixtures :all

  let(:described_class) { ::InchCI::Worker::Project::Build::SaveBuildData }
  let(:build) { Build.create!(:started_at => Time.now, :branch => Branch.first, :status => 'testing') }

  it "should only create code objects when they change" do
    build
    data = WorkerOutputMock.hash(:codebase_3_objects)
    assert_difference(%w(Build.count), 0) do
      assert_difference(%w(Revision.count RevisionDiff.count), 1) do
        assert_difference(%w(CodeObjectReference.count CodeObject.count CodeObjectDiff.count), 3) do
          described_class.new(build, data['build'])
        end
      end
    end

    # the changed data (after a supposed commit) now should only create
    # one new CodeObject since only one has changed. The others should only
    # be referenced in the new Revision.
    data = WorkerOutputMock.hash(:codebase_3_objects_1_changed)
    assert_difference(%w(Build.count), 0) do
      assert_difference(%w(Revision.count RevisionDiff.count), 1) do
        assert_difference(%w(CodeObjectReference.count), 3) do
          assert_difference(%w(CodeObject.count CodeObjectDiff.count), 1) do
            described_class.new(build, data['build'])
          end
        end
      end
    end
  end

  it "should handle retrieve_failed" do
    data = WorkerOutputMock.hash(:retrieve_failed)
    described_class.new(build, data['build'])
  end

  it "should handle change_branch_failed" do
    data = WorkerOutputMock.hash(:change_branch_failed)
    described_class.new(build, data['build'])
  end

  it "should handle checkout_revision_failed" do
    data = WorkerOutputMock.hash(:checkout_revision_failed)
    described_class.new(build, data['build'])
  end
end
