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
    @last_message_at = Time.now
  end

  def add_message(type:, message:)
    @last_message_at = Time.now
    messages << {
      type: type,
      message_content: message.content,
      timestamp: Time.now,
    }
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
