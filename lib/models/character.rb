require "lib/models/concerns/file_saveable"
require "lib/agents/character_backstory_agent"
require "lib/models/concerns/character_classes"
require "lib/models/campaign"

# Store Characters across multiple campaigns?
class Character
  include CharacterClasses
  include FileSaveable
  attr_accessor :id, :name, :dnd_class, :species, :level, :backstory, :campaigns, :summary

  def initialize(id: SecureRandom.uuid, name:, dnd_class:, species:, level:, backstory: nil, summary: nil, campaign_ids: [])
    @id = id
    @name = name
    @dnd_class = CLASSES[dnd_class] || CLASSES["Fighter"]
    @species = species
    @level = level
    @backstory = backstory
    @summary = summary
    @campaign_ids = campaign_ids
  end

  def armour_class
    dnd_class.ac
  end

  def max_hp
    level * (rand(1..dnd_class.hp_die) + dnd_class.con_mod)
  end

  def inspect
    base = "#{name} - Lvl #{level} #{species} #{dnd_class.name}"
    if summary
      "#{base} - #{summary}"
    else
      base
    end
  end

  def to_prompt(include_backstory: false)
    if include_backstory
      "#{inspect}\n\n#{backstory}"
    else
      inspect
    end
  end

  def to_hash
    {
      id: id,
      name: name,
      dnd_class: dnd_class.name,
      species: species,
      level: level,
      backstory: backstory,
      summary: summary,
      campaign_ids: @campaign_ids
    }
  end

  def generate_backstory
    CharacterBackstoryAgent.generate(character: self)
    self
  end

  def new?
    false
  end

  def campaigns
    @campaigns ||= @campaign_ids.map { |id| Campaign.find(id) }
  end

  def join_campaign(campaign)
    @campaign_ids << campaign.id
    campaigns.push(campaign)
    save
  end

  def max_hp
  end

  # Trying Null object pattern to handle the "Create a New Character" option.
  class NewCharacter
    def inspect
      "Create a New Character"
    end

    def new?
      true
    end
  end
end
