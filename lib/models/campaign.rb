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
  # [REMOVED] Mind-Bending Mystery: Uncover mysterious forces rooted in magic and the natural world.
  # Treasure Hunt: A quest for a hidden treasure or magical artifact.
  # Survival Adventure: An adventure focused on survival and exploration in a dangerous world.
  GENRES = ["Heroic Epic", "Politcal Noir", "Treasure Hunt", "Survival Adventure"]
  TONES = ["Lighthearted", "Optimistic", "Neutral", "Dramatic", "Bleak"]

  attr_reader :id
  attr_accessor :name, :genre, :tone, :world_info, :inciting_incident, :end_goal, :primary_antagonist, :npcs, :locations, :rumors, :hook

  # Maybe some of these attributes should be in separate classes. Revist as more features are added.
  def initialize(id: SecureRandom.uuid, name:, genre: nil, tone: nil, world_info:, inciting_incident:, end_goal:, primary_antagonist:, npcs:, locations:, rumors:, hook: "", log_id: nil)
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
    @hook = hook
    @log_id = log_id
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
      rumors: rumors,
      hook: hook
    }
  end

  def to_prompt
    <<~PROMPT
      ### Campaign Details
       Name: #{name}
       Genre: #{genre}
       Tone: #{tone}

      ### World & Plot Info: #{world_info}
       #{world_info}
      #### Inciting Incident
       #{inciting_incident}
      #### End Goal:
       #{end_goal}

       Primary Antagonist: #{primary_antagonist}
       NPCs: #{npcs.join(", ")}
       Locations: #{locations.join(", ")}
       Rumors: #{rumors.join(", ")}
    PROMPT
  end

  def new?
    false
  end

  def campaign_chats
    CampaignChat.for_campaign(id)
  end

  # Note: Low stakes really suck. They might be too boring to be worthwhile
  def self.generate(genre:, tone:, character: nil, stakes: nil)
    stakes ||= character&.difficulty_level || "Medium"
    CampaignGeneratorAgent.new(genre: genre, tone: tone, stakes: stakes).generate
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
