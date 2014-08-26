require 'test_helper'

describe Statistics do
  let(:date) { Time.now }

  it "should not save for the same date twice" do
    attributes = {
      :date => date,
      :name => "some-key",
      :value => 1
    }
    record = Statistics.new(attributes)
    assert record.save

    attributes = {
      :date => date,
      :name => "some-other-key",
      :value => 2
    }
    record2 = Statistics.new(attributes)
    assert record2.save

    bad_attributes = {
      :date => date,
      :name => "some-key",
      :value => 0
    }
    record3 = Statistics.new(bad_attributes)
    refute record.save
  end

end
