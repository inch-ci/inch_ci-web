require 'sidekiq/testing'

Sidekiq::Testing.inline!
Sidekiq::Logging.logger = nil
