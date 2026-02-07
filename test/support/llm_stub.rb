# frozen_string_literal: true

# Stub that mimics RubyLLM.chat's fluent API so BackstoryAgent (and other agents)
# can be tested without hitting the real Gemini API. Set REAL_LLM=1 to use the real API.

module TestSupport
  class LLMStub
    Response = Struct.new(:content, keyword_init: true)

    DEFAULT_BACKSTORY_CONTENT = {
      "backstory" => "A realm of ancient magic and rising darkness.",
      "npcs" => [
        { "name" => "The Shadow Lord", "description" => "Villain seeking the lost artifact." },
        { "name" => "Elder Mara", "description" => "Wise keeper of the village." }
      ],
      "plot" => "1. Heroes arrive. 2. Discover the threat. 3. Journey to the tower. 4. Final confrontation."
    }.freeze

    DEFAULT_LORE_CONTENT = "The artifact was forged in the First Age by the dwarven smiths of Khazad."
    DEFAULT_CHARACTER_CONTENT = {
      "backstory" => "A young human fighter from the village of Greenmeadow, seeking adventure and glory.",
      "summary" => "A young human fighter from the village of Greenmeadow, seeking adventure and glory."
    }.freeze

    class << self
      attr_accessor :backstory_content, :lore_content
    end
    self.backstory_content = DEFAULT_BACKSTORY_CONTENT
    self.lore_content = DEFAULT_LORE_CONTENT

    def with_instructions(_instructions)
      self
    end

    def with_schema(_schema)
      self
    end

    # TODO: store the prompts in an place both the agent and this stub can use it.
    #    Then check for the exact prompt content, return the correct response for the prompt, or raise for unknown prompts.
    def ask(prompt)
      # generate_backstory calls .ask("Generate a backstory for the campaign.")
      if prompt.to_s.include?("Generate a backstory")
        Response.new(content: self.class.backstory_content.dup)
      elsif prompt.to_s.include?("You will be provided the basic details of a DnD character.")
        Response.new(content: DEFAULT_CHARACTER_CONTENT.dup)
      else
        Response.new(content: self.class.lore_content.dup)
      end
    end

    def say(_context)
      ConversationStub.new(self.class)
    end

    class ConversationStub
      def initialize(klass)
        @klass = klass
      end

      def ask(_question)
        Response.new(content: @klass.lore_content.dup)
      end
    end
  end
end
