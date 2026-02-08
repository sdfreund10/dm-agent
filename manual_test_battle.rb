$LOAD_PATH.unshift(File.expand_path(".", __dir__))
require "lib/models/character"
require "lib/agents/campaign_agent"

player_character = Character.all.first
campaign = player_character.campaigns.first
campaign_agent = CampaignAgent.new(campaign, player_character)
message = <<~MESSAGE
  This is a test of the battle system.
  You will need to generate a battle between for a character called #{player_character.name}.
  First, add an ally to the player's party named "Bob the Barbarian".
  Then, start a battle by adding 5 goblins to the battlefield.
  Describe the situation and run the battles as you normally would according to your instructions. Pretend you are in the middle of a campaign.
MESSAGE
campaign_agent.run_test(
  initial_message: message
)
