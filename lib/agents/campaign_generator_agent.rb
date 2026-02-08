require "lib/config/ruby_llm"

# INPUTS
# TONE - player selection
# Genre - player selection
# Stakes - based on player level
# Character Backstory - character tie-ins
#
# OUTPUTS
# World
# End Goal
# Starting Situation (Inciting Incident)
# Key Locations
# Key NPCs (sepcify locations)

# POSSIBLE ADDITIONS
# Pillars of Play (Weighting): D&D generally sits on three pillars: Combat, Social Interaction, and Exploration
# Magic Density: Is this "High Magic" (teleporting circles in every city) or "Low Magic" (wizards are feared hermits)
#
# Rumors and Hooks - this might be a "situation" propety, but something that will give the player a hint what to do
#
#
# Tone Scale:
#   Lighthearted, Optimistic, Neutral, Dramatic, Bleak
# Genres
#   Heist, Mystery/Investigation, Survival, Treasure Hunt
#   EXTRAS: Exploration, Intrigue/Politics
class CampaignGeneratorAgent
  attr_reader :character, :tone, :genre
  def initialize(character:, tone:, genre:)
    @character = character
    @tone = tone
    @genre = genre
  end

  def generate
    chat = RubyLLM.chat.with_instructions(SYSTEM_INSTRUCTIONS).with_schema(CampaignGeneratorSchema)
    campaign_info = chat.ask(input).content
    name_response = chat.with_schema(nil).ask("Considering the overall plot, generate a short, 3-8 word name for the campaign.")
    campaign_info.merge!(
      name: name_response.content,
      genre: genre,
      tone: tone
    )
    Campaign.create(**campaign_info.transform_keys(&:to_sym))
  end

  def stakes
    case character.level
    when 1..3
      "Low"
    when 4..6
      "Medium"
    when 7..9
      "High"
    end
  end

  def input
    # SHOULD THIS INCLUDE CHARACTER BACKSTORY?
    # Character Backstory
    #{character.to_prompt(include_backstory: true)}
    <<~INPUT
      Tone: #{tone}
      Genre: #{genre}
      Stakes: #{stakes}
    INPUT
  end

  # TODO: Way too many of the campaigns take place in "Oakhaven" and deal with "the blight". Need to add some veriablility. Maybe just adjust the temperature?
  SYSTEM_INSTRUCTIONS = <<~SYSTEM
    You are an Expert Dungeon Master building a short campaign for new party.
    You will be given the character's backstory and a tone and genre for the campaign.
    Your goal is to generate a plot and supporting material for the campaign.
    STEPS:
    1. Consider the desired tone and create a world that matches it.
    2. Define a goal or ending point of a campaign within that world.
    3. Consider the primary antagonist of this quest and supporting npcs.
    4. Consider key locations the party will likely need to visit as they uncover the plot.
    5. Develop an inciting incident that will introduce the party to the world.
      - This does not need to be directly related to the plot, but it should lead in to the plot in some way.
    6. Develop 2-3 hooks that will help the party start on thier quest.
  SYSTEM

  class CampaignGeneratorSchema < RubyLLM::Schema
    string :end_goal, description: "The primary goal of the campaign."
    string :inciting_incident, description: "Starting situation for the campaign."
    string :world_info, description: "Supporting information about the setting and larger world of the campaign."
    string :primary_antagonist, description: "The primary antagonist of the campaign."
    array :npcs, description: "Important NPCs in the campaign." do
      object do
        string :name
        string :description
      end
    end
    array :locations, description: "Key locations in the campaign." do
      object do
        string :name
        string :description
      end
    end
    array :rumors, of: :string, description: "Rumors and Hooks in the campaign."
  end
end
