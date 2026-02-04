require "ruby_llm"
require "ruby_llm/schema"

require "lib/config/ruby_llm"

module Agents
  class BackstoryAgent
    class WorldSchema < RubyLLM::Schema
      string :backstory, description: "Supporting material about the world relevant to the campaign."
      array :characters, description: "Important NPCs in the campaign." do
        object do
          string :name
          string :description
        end
      end
      string :plot, description: "The primary plot of the campaign."
    end

    attr_reader :world
    def initialize(world:)
      @world = world
    end

    # Run on creation of the world to geneate the lore and story for the campaign.
    def generate_backstory
      response = RubyLLM.chat.with_instructions(BACKSTORY_INSTRUCTIONS).with_schema(WorldSchema).ask("Generate a backstory for the campaign.")
      content = response.content
      world.backstory = content["backstory"]
      world.characters = content["characters"]
      world.plot = content["plot"]
    end

    BACKSTORY_INSTRUCTIONS = <<~SYSTEM
      You are an expert Dungeon master in the game Dungeons & Dragons who is expecially skilled at creating worlds and stories.
      You are creating a the world and plot for a new campaign. Your players will give you some properties of the campaign they would like to play.
      Your task is to create the major plot and conflicts of a story within the world of Dungeons & Dragons.
      You should generate the central theme and conflicts, as well as a path you'd like the players to follow, but the actual story will be influenced by the players.
      You're story should contain a clear beginning and end, with enough details to fill in the middle as the story unfolds.
      Limit the backstory to 1000 words.


      After creating a backstory, create a list of key plot points for the players to follow. They should start with an entrypoint accessible to lower level characters, and work up in to the larger conflict.
      The plot should contain a list of 10-15 key story points.
    SYSTEM

    # ask specific questions to fill in info about the world.
    def ask(question:)
      conversation = chat.with_instructions(LORE_INSTRUCTIONS).with_schema(WorldSchema).say(world.summary)
      response = conversation.ask(question)
      response.content
    end

    LORE_INSTRUCTIONS = <<~SYSTEM
      You are an expert Dungeon master in the game Dungeons & Dragons who is expecially skilled at creating worlds and stories.
      You are running a campaign and need to fill in some lore because of the players' actions.
      Use the existing backstory and plot to fill in more lore.
      Only return the the additional lore. This will be appended to the existing world information.
      Limit your response to 100 words.
    SYSTEM
  end
end
