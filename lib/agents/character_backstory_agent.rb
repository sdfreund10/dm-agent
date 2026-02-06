require "ruby_llm"
require "ruby_llm/schema"

require "lib/config/ruby_llm"

class CharacterBackstoryAgent
  attr_reader :character
  def initialize(character:)
    @character = character
  end

  def generate
    response = RubyLLM.chat.with_instructions(SYSTEM_INSTRUCTIONS).with_schema(CharacterBackstorySchema).ask(character.to_prompt(include_backstory: false))
    character.backstory = response.content["backstory"]
    character.summary = response.content["summary"]
    character
  end

  def self.generate(character:)
    new(character: character).generate
  end

  class CharacterBackstorySchema < RubyLLM::Schema
    string :backstory, description: "The character's backstory."
    string :summary, description: "A short, one sentence summary of the character's backstory and/or personality."
  end

  SYSTEM_INSTRUCTIONS = <<~SYSTEM
    You will be provided the basic details of a DnD character.
    Generate a brief backstory for the charactdr.

    The backstory should answer most ofthe following questions:
    Why is the character adventuring?
    What motivates the character? (Helping others, serving a cause, money, power, knowledge, etc.)
    Where is the chracter from? Do they have any secrets orspecial attachments?
    What are thier strengths and weaknesses?

    Limit the backstory to 200 words.
    Also include a short, ~20 word summary of the character's backstory and/or motivation.
  SYSTEM
end
