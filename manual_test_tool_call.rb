$LOAD_PATH.unshift(File.expand_path(".", __dir__))
require "lib/config/ruby_llm"

class AdditionCalculator < RubyLLM::Tool
  description "Calculate the sum of two numbers."
  params do
    integer :a, description: "The first number."
    integer :b, description: "The second number."
  end

  def execute(a:, b:)
    a + b
  end
end

def main
  puts "Starting chat..."
  chat = RubyLLM.chat.with_tools(AdditionCalculator)
  response = chat.ask("What is 1 + 1?") do |message|
    print message.to_h
  end

  puts
  puts response.content
end

if __FILE__ == $0
  main
end
