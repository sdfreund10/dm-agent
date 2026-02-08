require "securerandom"
require "json"
require "lib/models/concerns/file_saveable"

class Log
  include FileSaveable
  storage_key "logs"

  attr_reader :id, :campaign_id, :player_character_id, :messages
  def initialize(id: SecureRandom.uuid, campaign_id:, player_character_id:,messages:)
    @id = id
    @campaign_id = campaign_id
    @player_character_id = player_character_id
    @messages = messages
  end

  def add_message(type:, message:)
    messages << { type: type, message: message }
    save
  end

  def to_hash
    {
      id: id,
      campaign_id: campaign_id,
      player_character_id: player_character_id,
      messages: messages
    }
  end
end
