require "securerandom"
require "json"
require "lib/models/concerns/file_saveable"
require "lib/agents/campaign_generator_agent"

# File-backed ORM
#  - Each record is a JSON named like <model-name>-<uuid>.json
#
class Campaign
  include FileSaveable
  storage_key "campaigns"

  # Heoric Epic: Classic heroic fantasy with a clear and grand goal.
  # Politcal Noir: Heavily social adventure focussed on uncovering conspiracies and taking sides.
  # Mind-Bending Mystery: Uncover mysterious forces rooted in magic and the natural world.
  # Treasure Hunt: A quest for a hidden treasure or magical artifact.
  # Survival Adventure: An adventure focused on survival and exploration in a dangerous world.
  GENRES = ["Heroic Epic", "Politcal Noir", "Mind-Bending Mystery", "Treasure Hunt", "Survival Adventure"]
  TONES = ["Lighthearted", "Optimistic", "Neutral", "Dramatic", "Bleak"]

  attr_reader :id
  attr_accessor :name, :genre, :tone, :world_info, :inciting_incident, :end_goal, :primary_antagonist, :npcs, :locations, :rumors

  # Maybe some of these attributes should be in separate classes. Revist as more features are added.
  def initialize(id: SecureRandom.uuid, name:, genre:, tone:, world_info:, inciting_incident:, end_goal:, primary_antagonist:, npcs:, locations:, rumors:)
    @id = id
    @name = name
    @genre = genre
    @tone = tone
    @world_info = world_info
    @inciting_incident = inciting_incident
    @end_goal = end_goal
    @primary_antagonist = primary_antagonist
    @npcs = npcs
    @locations = locations
    @rumors = rumors
  end

  def inspect
    "#{name} - #{genre} - #{tone}"
  end

  def to_hash
    {
      id: id,
      name: name,
      genre: genre,
      tone: tone,
      world_info: world_info,
      inciting_incident: inciting_incident,
      end_goal: end_goal,
      primary_antagonist: primary_antagonist,
      npcs: npcs,
      locations: locations,
      rumors: rumors
    }
  end

  def new?
    false
  end

  def self.generate(genre:, tone:, character:)
    CampaignGeneratorAgent.new(genre: genre, tone: tone, character: character).generate
  end

  class NewCampaign
    def inspect
      "Create a New Campaign"
    end

    def new?
      true
    end
  end
end
