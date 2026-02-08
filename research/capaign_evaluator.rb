$LOAD_PATH.unshift(File.expand_path("..", __dir__))
require "ruby_llm"
require "ruby_llm/schema"

require "lib/config/ruby_llm"
require "lib/models/log"
require "lib/models/campaign"
require "lib/models/character"

class CampaignEvaluator
  attr_reader :log, :campaign, :player_character
  def initialize(log_id:)
    @log = Log.find(log_id)
    @campaign = Campaign.find(log.campaign_id)
    @player_character = Character.find(log.player_character_id)
  end

  def evaluate
    response = RubyLLM.chat.with_instructions(EVALUATION_INSTRUCTIONS).ask(prompt)
    response.content
  end

  def prompt
    log_summary = @log.messages.map do |message|
      "#{message["type"] == "user" ? "Player" : "DM"}: #{message["message"]}"
    end

    <<~PROMPT
      ## Campaign Details
      #{@campaign.to_prompt}

      ## Character Details
      #{@player_character.to_prompt(include_backstory: true)}

      ## Campaign Logs
      #{log_summary.join("\n")}
    PROMPT
  end

  EVALUATION_INSTRUCTIONS = <<~SYSTEM
    You are an expert Dungeon Master evaluating a campaign.
    You will be given the log of a campaign and a character.
    Your goal is to evaluate the DM's performance and provide feedback.

    Please descibe what the DM did well and how they could improve.
    Take your time and be specific.
  SYSTEM
end

if __FILE__ == $0
  LOG_ID = "35809080-c345-4359-9fdb-c865c12e0ad8"
  evaluator = CampaignEvaluator.new(log_id: LOG_ID)
  puts evaluator.evaluate
end
