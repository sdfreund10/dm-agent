# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../", __dir__))
ENV["APP_ENV"] = "test"
require "minitest"
require "minitest/autorun"
require "minitest/reporters"

# clear data directory
Dir.glob('data/test/**/*.json').each do |file|
  File.delete(file)
end

# Stub RubyLLM so tests don't hit the real API. Set REAL_LLM=1 to use the real Gemini API.
require "ruby_llm"
require "lib/config/ruby_llm"
require "test/support/llm_stub"

unless ENV["REAL_LLM"].to_s =~ /\A(1|true|yes)\z/i
  RubyLLM.define_singleton_method(:chat) { TestSupport::LLMStub.new }
end

require "test/support/factories"
Minitest::Test.include(TestSupport::Factories)

# Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)
