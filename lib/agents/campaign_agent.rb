require "ruby_llm"
require "ruby_llm/schema"

require "lib/config/ruby_llm"
require "lib/models/log"

class CampaignAgent
  attr_reader :campaign, :player_character, :log
  def initialize(campaign, player_character)
    @campaign = campaign
    @player_character = player_character
    @chat = RubyLLM.chat.with_instructions(SYSTEM_INSTRUCTIONS)
    @log = Log.new(campaign_id: campaign.id, player_character_id: player_character.id, messages: [])
  end

  def run(message:)
    log.add_message(type: "user", message: message)
    response = @chat.ask(message)
    log.add_message(type: "system", message: response.content)
    puts "(#{response.input_tokens} input + #{response.output_tokens} output)"
    response.content
  end

  def start!
    starting_message = @chat.ask(starting_prompt)
    log.add_message(type: "system", message: starting_message.content)
    starting_message.content
  end

  # TOOL: Combat Agent
  #   The larger agent does not do a very good job of running combat.
  #   I think a specialize agent that recieves monster and player HPs will help it track better.

  def starting_prompt
    <<~PROMPT
      ## Start the following campaign by describing the inciting incident and the player's immediate goals.
      #{@campaign.to_prompt}

      ## Character Details
      #{@player_character.to_prompt(include_backstory: true)}
    PROMPT
  end


  SYSTEM_INSTRUCTIONS = <<~PROMPT
    You are a Dungeon Master for a D&D campaign.
    You will be given the details of a campaign and a character.
    Your goal is run the campaign.
    You will build the situation and play all of the npcs, but the player will drive the plot and decide what to do.
    Gently guide the player towards the campaign goal by telling them about their immediate surroundings and through dialogue with NPCS.

    GUIDELINES:
    - When starting the campaign, describe the inciting situation and what the characters know.
    - Never reveal too much information to the player.

    ACTIONS:
    - Describe the immediate surroundings.
    - Ask the player to roll dice for a skill check.
      - Any time the player wants to take an action or discern information, consider if the player could make a skill check to do it.
      - Difficult actions should require a 15+ roll to succeed. Easy actions should require a 5+ roll to succeed. Intermediate actions should require a 10+ roll to succeed.
      - If the player rolls below the target number, they should fail, or partially fail the action.
    - Talk to the character via dialogue with NPCs.
    - Attack the player with a monster or NPCs, if it makes sense in response to the player's actions.
  PROMPT
end
