require "cli/base_interface"
require "cli/inputs"
require "lib/models/campaign"
require "lib/models/character"

module CLI
  class CampaignSelection < BaseInterface
    include Inputs
    attr_reader :campaigns, :selected_campaign, :selected_character

    def initialize
      @characters = Character.all
    end

    def run
      select_character
      select_campaign
      self
    end

    def select_campaign
      selection = select_option("Select a campaign:", campaign_options)
      if selection.new?
        @selected_campaign = CampaignCreation.run(@selected_character)
      else
        @selected_campaign = selection
      end
    end

    def select_character
      selection = select_option("Select a character:", character_options)
      if selection.new?
        @selected_character = CharacterCreation.run
      else
        @selected_character = selection
      end
    end

    private

    def character_options
      @characters + [::Character::NewCharacter.new]
    end

    def campaign_options
      if @selected_character.nil?
        []
      else
        @selected_character.campaigns + [::Campaign::NewCampaign.new]
      end
    end
  end

  class CharacterCreation < BaseInterface
    include Inputs

    def run
      character_name = get_input("What is your character's name?")
      character_class = select_option("What is your character's class?", ::Character::CLASSES.keys)
      character_species = select_option("What is your character's species?", ["Human", "Elf", "Dwarf", "Halfling", "Gnome", "Half-Elf", "Half-Orc", "Tiefling", "Aasimar", "Dragonborn"])
      player_level = select_option("What is your character's level?", ["3", "6", "9", "12"])
      character = Character.new(name: character_name, dnd_class: character_class, species: character_species, level: player_level, backstory: nil)

      generate_backstory = yes_no_input("Would you like me to generate a backstory for your character?")
      if generate_backstory
        character.generate_backstory
      else
        backstory = get_input("Enter your character's backstory:")
        character.backstory = backstory
      end

      puts "Character created: #{character.inspect}"
      puts "Backstory: #{character.backstory}"
      character.save
      character
    end
  end

  class CampaignCreation < BaseInterface
    include Inputs

    def run(selected_character)
      tone = select_tone
      genre = select_genre
      puts "Generating campaign..."
      campaign = ::Campaign.generate(genre: genre, tone: tone, character: selected_character)
      puts "Campaign created: #{campaign.inspect}"
      selected_character.join_campaign(campaign)
      campaign
    end

    def select_tone
      options = ::Campaign::TONES
      select_option("Select an overall tone for the world and campaign:", options)
    end

    def select_genre
      options = ::Campaign::GENRES
      select_option("Select a genre for your adventure:", options)
    end
  end
end
