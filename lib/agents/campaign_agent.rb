require "ruby_llm"
require "ruby_llm/schema"

require "lib/config/ruby_llm"
require "lib/models/log"

class CampaignAgent
  attr_reader :campaign, :player_character, :log
  def initialize(campaign, player_character)
    @campaign = campaign
    @player_character = player_character
    @battle_manager = BattleManager.new(player_character)
    @battle_mode = false
    @chat = RubyLLM.chat.with_instructions(SYSTEM_INSTRUCTIONS).with_tools(
      SkillCheck,
      AddAlly.new(@battle_manager, self),
      AddEnemy.new(@battle_manager, self),
      EndBattle.new(@battle_manager, self),
      UserAttack.new(@battle_manager, self),
      NPCAttack.new(@battle_manager, self),
      HealCharacter.new(@battle_manager, self)
    ).on_end_message do |message|
      if @battle_mode && message.role == :assistant && message.content.strip.length > 0
        puts message.content
      end
    end
    @log = Log.new(campaign_id: campaign.id, player_character_id: player_character.id, messages: [])
    @input_token_count = 0
  end

  def run(message:)
    log.add_message(type: "user", message: message)
    response = @chat.ask(message)
    log.add_message(type: "system", message: response.content)
    puts "(#{response.input_tokens} input + #{response.output_tokens} output)"
    response.content
  end

  # Provide a block describing how to render the system message to the user.
  def run_loop
    starting_message = @chat.ask(starting_prompt)
    log.add_message(type: "system", message: starting_message.content)
    system_message = starting_message.content
    while true
      message = yield system_message
      log.add_message(type: "user", message: message)
      response = @chat.ask(message)
      system_message = response.content

      # INTERNAL LOGGING
      log.add_message(type: "system", message: response.content)
      @input_token_count = response.input_tokens
      puts "(#{response.input_tokens} input + #{response.output_tokens} output)"
      if @input_token_count > 100_000
        puts "WARNING: Input token count is over 200,000. Consider breaking the conversation into smaller chunks."
      end
    end
  end

  # During battle, there is are a lot of tool calls that can get lost if we just print the last message to the user.
  # This prints out the intermediate messages so the user gets a full picture of what happens each turn of combat.
  def enable_battle_mode!
    @battle_mode = true
  end

  def disable_battle_mode!
    @battle_mode = false
  end

  def run_test(initial_message:)
    @chat = @chat.on_tool_call do |tool_call|
      # Called when the AI decides to use a tool
      # puts "Calling tool: #{tool_call.name} with arguments: #{tool_call.arguments}"
      # puts "Arguments: #{tool_call.arguments}"
    end
    .on_tool_result do |result|
      # Called after the tool returns its result
      # puts "Tool returned: #{result}"
    end
    .on_new_message do
      # puts "Received response from AI..."
    end
    .on_end_message do |message|
      # puts "----#{message.role} (#{message.role == :assistant})----"
      if @battle_mode && message.role == :assistant && message.content.strip.length > 0
        puts message.content
      end
      # puts "Message: (#{message.role}) #{message&.content}"
      # puts message.class, message&.content.strip.length
      # puts "Finished processing AI actions. Proceeding..."
      # puts "--------------------------------"
      # puts "Receiving message from AI:"
      # puts message.content
      # puts "--------------------------------"
    end
    # .on_end_message do |message|
    #   if @battle_mode && message.role == "assistant"
    #     puts message.content
    #   end
    # end

    puts "Testing agent with following instructions:"
    puts "--------------------------------"
    system_message = @chat.ask(initial_message)
    while true
      puts "--------------------------------"
      puts "System Message:"
      puts system_message.content
      puts "--------------------------------"
      user_message = nil
      until user_message && user_message.strip.length > 0
        user_message = gets.chomp
      end
      user_message.strip!
      system_message = @chat.ask(user_message)
    end
  end

  # TOOL: Combat Agent
  #   The larger agent does not do a very good job of running combat.
  #   I think a specialize agent that recieves monster and player HPs will help it track better.
  # TODO: I think it's sending messages in response to tool calls that are not visible to the user, causing half of combat to be invisible to the player.
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
    - Secretly perform skill checks for NPC actions.
    - Add allies to the player party.
    - Start a battle between the player party and monsters.

    HOW TO RUN A BATTLE:
    1. At the start of the battle, add the enemies to the battlefield.
    2. On every turn, describe the actions of every character in the battle.
    3. Parse the player's actions and apply the correct attacks or other effects.
    4. Process attacks for allies by determining target, attack bonus, and damage.
    5. Process all enemy attacks by determining target, attack bonus, and damage.
    6. Keep track of enemy HP, but do not reveal the exact HP values to the player. Only reveal when they are dead.
    7. At the end of every turn, summarize everything that happened last turn.
    8. Continue the battle until all enemies are defeated or the player party is defeated.
  PROMPT

  ## STATE ##
  class BattleManager
    # TODO: Better name
    PlayerStruct = Struct.new(:id, :name, :hp, :max_hp, :armour_class)
    def initialize(player_character)
      # TODO: Dynamic HP
      @player_character = PlayerStruct.new(0, player_character.name, 30, 30, player_character.armour_class)
      @next_id = 1
      @allies = []
      @enemies = []
    end

    def characters
      [@player_character, *@allies, *@enemies]
    end

    def add_ally(name:, max_hp:, armour_class:)
      @allies << PlayerStruct.new(@next_id, name, max_hp, max_hp, armour_class)
      @next_id += 1
      self
    end

    def add_enemy(name:, max_hp:, armour_class:)
      @enemies << PlayerStruct.new(@next_id, name, max_hp, max_hp, armour_class)
      @next_id += 1
      self
    end

    def end_battle
      @enemies = []
      self
    end

    def adjust_hp(character_id:, hp_change:)
      character = characters.find { |character| character.id == character_id }
      if character.nil?
        return "Character not found. Try again with the correct id."
      end
      character.hp += hp_change
    end

    def attack_character(character_id:, damage:, attack_roll:)
      character = characters.find { |character| character.id == character_id }
      if character.nil?
        return "Character not found. Try again with the correct id."
      end

      if attack_roll >= character.armour_class
        character.hp -= damage
        return "Rolled #{attack_roll} and Hit!"
      else
        return "Rolled #{attack_roll} and Missed!"
      end
    end


    def to_prompt
      # IDEA: Have the enemy HP map to descriptions like "a few wounds", "pretty hurt", "heavily wounded", "near death", "dead".
      <<~PROMPT
        ## Player Party
        #{format_character(@player_character)}
        #{@allies.map { |ally| format_character(ally) }.join("\n")}

        ## Enemies
        #{@enemies.map { |enemy| format_character(enemy) }.join("\n")}
      PROMPT
    end

    def format_character(character)
      "#{character.name} - id: #{character.id} - HP: #{character.hp}/#{character.max_hp}"
    end
  end


  ### TOOLS ###
  class SkillCheck < RubyLLM::Tool
    description "Roll a d20 for an NPC skill check, NPC saving throw, or just to implement a random outcome."

    params do
      integer :check_threshold, description: "The threshold for the check. (e.g., 15 for hard checks, 10 for medium checks, 5 for easy checks, etc.)"
      integer :bonus, description: "A bonus to the check. Should be 0, unless character has an active effect that provides a bonus."
    end

    def execute(check_threshold:, bonus: 0)
      roll = rand(1..20) + bonus.to_i
      { roll: roll, success: roll >= check_threshold }
    end
  end

  # CAN I ROLL DAMAGE AS PART OF THE ATTACK TOOL?
  # class DamageRoll < RubyLLM::Tool
  #   description "Roll damage for an NPC attack."
  #   params do
  #     integer :die_size, description: "The size of the die to roll. 4 for weak attacks, 10 or 12 for very strong attacks.", enum: [4, 6, 8, 10, 12]
  #     integer :num_dice, description: "How many dice to roll. Usually 1 per attack, but can roll multiple attacks at once.", default: 1
  #   end

  #   def execute(damage:)
  #     min_damage = num_dice
  #     max_damage = num_dice * die_size
  #     damage = rand(min_damage..max_damage)
  #     { key: "#{num_dice}d#{die_size}", damage: damage }
  #   end
  # end

  class BattleToolBase < RubyLLM::Tool
    def initialize(battle_manager, campaign_agent)
      @battle_manager = battle_manager
      @campaign_agent = campaign_agent
    end
  end

  class AddAlly < BattleToolBase
    description "Add an ally to the player party."
    params do
      string :name, description: "The name of the ally."
      integer :max_hp, description: "The maximum health of the ally."
      integer :armour_class, description: "The armour class of the ally. Minimum 10 for weak allies, 13 for most allies, 15+ for strong allies."
    end

    def execute(name:, max_hp:, armour_class:)
      @battle_manager.add_ally(name: name, max_hp: max_hp, armour_class: armour_class)
      { success: true, status: @battle_manager.to_prompt }
    end
  end

  class AddEnemy < BattleToolBase
    description "Add an enemy to the battlefield."
    params do
      string :name, description: "The name of the enemy."
      integer :max_hp, description: "The maximum health of the enemy."
      integer :armour_class, description: "The armour class of the enemy. Minimum 10 for weak enemies, 13 for most enemies, 15+ for strong enemies."
    end

    def execute(name:, max_hp:, armour_class:)
      @battle_manager.add_enemy(name: name, max_hp: max_hp, armour_class: armour_class)
      @campaign_agent.enable_battle_mode!
      @battle_manager.to_prompt
    end
  end

  class EndBattle < BattleToolBase
    description "End a battle between the player party and monsters."
    def execute
      @battle_manager.end_battle
      @campaign_agent.disable_battle_mode!
      { success: true, status: @battle_manager.to_prompt }
    end
  end

  class NPCAttack < BattleToolBase
    description "Attack a character with an NPC attack."
    params do
      integer :character_id, description: "The id of the character to attack."
      integer :damage_die, description: "The size of the die to roll for damage. 4 for very weak attacks, 10 or 12 for very strong attacks." #, enum: [4, 6, 8, 10, 12]
      integer :num_dice, description: "How many dice to roll for damage. Usually 1 per attack, but can roll multiple attacks at once." # , default: 1
      integer :attack_bonus, description: "Attacking character's bonus to hit. Minimum 0 for weak attackers, 1-3 for most attackers, 4-6 for very strong attackers." # , default: 0
    end

    def execute(character_id:, damage_die:, num_dice:, attack_bonus:)
      damage_roll = num_dice.times.map { rand(1..damage_die) }.sum
      attack_roll = rand(1..20) + attack_bonus
      result = @battle_manager.attack_character(character_id: character_id, damage: damage_roll, attack_roll: attack_roll)
      { result: result, status: @battle_manager.to_prompt }
    end
  end

  class HealCharacter < BattleToolBase
    description "Heal a character by a given amount."
    params do
      integer :character_id, description: "The id of the character to adjust."
      integer :hp_change, description: "How much to heal the character by. Should be positive."
    end

    def execute(character_id:, hp_change:)
      @battle_manager.adjust_hp(character_id: character_id, hp_change: hp_change)
      { success: true, status: @battle_manager.to_prompt }
    end
  end

  class UserAttack < BattleToolBase
    description "Use this when the user attacks an enemy. The user will provide the attack roll and damage."
    params do
      integer :character_id, description: "The id of the character to attack."
      integer :attack_roll, description: "The player-provided attack roll."
      integer :damage, description: "The player-provided damage."
    end

    def execute(character_id:, attack_roll:, damage:)
      result = @battle_manager.attack_character(character_id: character_id, damage: damage, attack_roll: attack_roll)
      { result: result, status: @battle_manager.to_prompt }
    end
  end
end
