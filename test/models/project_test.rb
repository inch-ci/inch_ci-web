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

  test "should save record with well-formed UID" do
    good_attributes = {
      :uid => "github:alakra/weather-forecasts",
      :repo_url => "https://github.com/rrrene/repomen.git"
    }
    record = Project.new(good_attributes)
    assert record.save
  end

end
