$LOAD_PATH.unshift(File.expand_path(".", __dir__))
require "lib/models/campaign"
require "cli/campaign_selection"
require "lib/agents/campaign_creator_agent"

class CLI::Main
  def self.run
    new.run
  end

  def run
    welcome_message
    campaign_selection = ::CLI::CampaignSelection.run
    puts "Campaign selected: #{campaign_selection.selected_campaign.name}"
    puts "Character selected: #{campaign_selection.selected_character.name}"
    # show_main_menu
  end

  private

  def welcome_message
    puts "\n" + "=" * 60
    puts "  Welcome! I am your AI Dungeon Master!"
    puts "=" * 60
    puts "\n"
  end
end

# Run the CLI if this file is executed directly
if __FILE__ == $0
  CLI::Main.run
end
