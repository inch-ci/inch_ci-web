ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

module TestHelper
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

  # Logs a given +user+ in, executes the given block and logs the user out.
  def with_login(user = User.first, &block)
    session[:user_id] = user.id
    yield(user)
    session[:user_id] = nil
  end
end

require 'support/mini_test_spec'
require 'support/worker_output_mock'
require 'support/sidekiq'
require 'support/omniauth'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include TestHelper
end
