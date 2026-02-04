require "ruby_llm"
require "dotenv/load"

# 1,048,576 context window limit for Gemini 2.5 Flash
# try to limit total input to 10k tokens
RubyLLM.configure do |config|
  # config.openai_api_key = ENV['OPENAI_API_KEY'] || Rails.application.credentials.dig(:openai_api_key)
  config.default_model = "gemini-2.5-flash"
  config.default_image_model = "gemini-2.5-flash-image"

  config.gemini_api_key = ENV['GEMINI_API_KEY']
  config.anthropic_api_key = ENV['ANTHROPIC_API_KEY']
end
