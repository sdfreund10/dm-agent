require "securerandom"
require "json"
require "lib/models/concerns/file_saveable"

# File-backed ORM
#  - Each record is a JSON named like <model-name>-<uuid>.json
#
class Campaign
  include FileSaveable
  storage_key "campaigns"

  attr_reader :id, :world
  attr_accessor :name

  def initialize(id: SecureRandom.uuid, name: nil, world_params: {})
    @id = id
    @name = name
    @world = World.new(campaign: self, **world_params)
  end

  def set_up
    world.generate_backstory
  end

  def to_hash
    {
      id: id,
      name: name,
      world: world.to_hash
    }
  end

  def to_json
    to_hash.to_json
  end

  def new?
    false
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
