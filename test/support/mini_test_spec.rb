
require 'minitest/autorun'
require 'active_support/testing/assertions'

class MiniTest::Spec
  include ActiveSupport::Testing::Assertions
  include ActiveSupport::Testing::SetupAndTeardown
  include ActiveRecord::TestFixtures

  alias :method_name :name if defined? :name

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

  def assert_badge(base)
    InchCI::Badge.each_image_combination do |format, style|
      file = File.join(base, "master.#{style}.#{format}")
      assert File.exist?(file), "File #{file} not found"
    end
  end
end
