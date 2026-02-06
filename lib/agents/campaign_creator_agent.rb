require "ruby_llm"
require "ruby_llm/schema"

require "lib/config/ruby_llm"

# DEPRECATED: This agent was slower and less reliable than I would like.
class CampaignCreatorAgent
  # prompt the user with questions until they have provided enough information to create a campaign.
  # What information is needed?
  #   - Character name, class, race
  #   - Player lvl (for level scaling)
  #   - What type of campaign they want to play
  #     - Examples: Heist, Intrigue/Politics, Mystery/Investigation, Survival, Treasure Hunt, War, Exploration
  #
  # Example Usage:
  # ampaign_creator = CampaignCreatorAgent.new
  # campaign_creator.answer("Charlie")
  # while !campaign_creator.complete?
  #   response = get_input(campaign_creator.next_question)
  #   campaign_creator.answer(response)
  # end
  # puts campaign_creator.results

  attr_reader :chat
  def initialize
    @chat = RubyLLM.chat.with_instructions(SYSTEM_INSTRUCTIONS).with_schema(CampaignCreatorSchema)
    @complete = false
  end

  def answer(user_message)
    response = chat.ask(user_message)
    if response.content["is_complete"]
      @complete = true
      response.content
    else
      response.content["next_question"]
    end
  end

  def next_question
    chat.messages.last.content["next_question"]
  end

  def complete?
    @complete
  end

  def results
    if complete?
      chat.messages.last.content["campaign_info"]
    else
      nil
    end
  end

  # TODO: Right now this agent is fully driving the conversation. Maybe it'd be more efficient and reliable to ask
  # basic question first, then hand off the transcript to the agent to fill in the gaps.
  SYSTEM_INSTRUCTIONS = <<~SYSTEM
    You are an assistant to a Dungeon and Dragons Dungeon Master.
    Your taks is to collect information from the players so your DM can create a campaign around the players' preferences.

    You will need to collect the following information:
    - Character name, class, species
    - Player level (for level scaling)
    - The type of campaign the players would like to play
      - examples: Heist, Intrigue/Politics, Mystery/Investigation, Survival, Treasure Hunt, Exploration

    PROCESS:
    1) Analyze the provided information and determine what information is missing.
    2) If there is any missing information, ask the player for the the missing information one piece at a time.
    3) If any information feels imcomplete or unclear, you may ask clarifying questions.
    4) Once you have all the information, return the information to the DM.

    You will start off with the character's name and will take over the questioning from there.
    Provide examples or questions to help the player build their character.
    The player may provide multiple pieces of information at the same time, such as "Lvl 9 Monk".
    Only return campaign info that is provided by the player. Do not make up information. You may correct typos and misspellings.
  SYSTEM

  class CampaignCreatorSchema < RubyLLM::Schema
    boolean :is_complete, description: "Whether the campaign creator has provided enough information to create a campaign."
    string :next_question, description: "The next question to ask the player."
    object :campaign_info, description: "Information to build the campaign." do
      string :character_name
      string :character_class, enum: ["Barbarian", "Bard", "Cleric", "Druid", "Fighter", "Monk", "Paladin", "Ranger", "Rogue", "Sorcerer", "Warlock", "Wizard"]
      string :character_species, enum: ["Human", "Elf", "Dwarf", "Halfling", "Gnome", "Half-Elf", "Half-Orc", "Tiefling", "Aasimar", "Dragonborn"]
      string :player_level, enum: ["3", "4", "5", "6", "7", "8", "9", "10"]
      string :campaign_type, description: "The type of campaign the players would like to play."
    end
  end
end
