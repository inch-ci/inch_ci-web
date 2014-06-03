require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  test "should not save record with malformed UID" do
    bad_attributes = {
      :uid => "github:rrrene/sparkr/",
      :repo_url => "https://github.com/rrrene/sparkr.git"
    }
    record = Project.new(bad_attributes)
    refute record.save
  end
end
