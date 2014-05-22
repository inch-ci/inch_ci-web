
require "minitest/reporters"
Minitest::Reporters.use!

require 'minitest/autorun'
require 'active_support/testing/assertions'

class MiniTest::Spec
  include ActiveSupport::Testing::Assertions
  include ActiveSupport::Testing::SetupAndTeardown
  include ActiveRecord::TestFixtures
  alias :method_name :__name__ if defined? :__name__
  self.fixture_path = File.join(Rails.root, 'test', 'fixtures')

  def assert_positive_difference(expression, message = nil, &block)
    expressions = Array(expression)

    exps = expressions.map { |e|
      e.respond_to?(:call) ? e : lambda { eval(e, block.binding) }
    }
    before = exps.map { |e| e.call }

    yield

    expressions.zip(exps).each_with_index do |(code, e), i|
      error  = "#{code.inspect} didn't increase"
      error  = "#{message}.\n#{error}" if message
      assert(e.call - before[i] > 0, error)
    end
  end
end