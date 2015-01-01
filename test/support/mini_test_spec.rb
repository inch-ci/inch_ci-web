
require 'minitest/autorun'
require 'active_support/testing/assertions'

class MiniTest::Spec
  include ActiveSupport::Testing::Assertions
  include ActiveSupport::Testing::SetupAndTeardown
  include ActiveRecord::TestFixtures

  include TestHelper

  alias :method_name :name if defined? :name

  self.fixture_path = File.join(Rails.root, 'test', 'fixtures')
end
