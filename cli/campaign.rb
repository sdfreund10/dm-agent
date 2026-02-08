require "cli/base_interface"
require "cli/inputs"
require "lib/agents/campaign_agent"
module CLI
  class Campaign < BaseInterface
    include Inputs

    def initialize(campaign, player_character)
      @campaign = campaign
      @player_character = player_character
      @campaign_agent = CampaignAgent.new(campaign, player_character)
    end

    def run
      puts "Getting your adventure ready..."

      @campaign_agent.run_loop do |system_message|
        puts "--------------------------------"
        puts system_message
        puts "--------------------------------"
        user_input = get_input("What would you like to do? (type 'exit' to end the campaign)")
        if user_input.downcase == "exit"
          break
        else
          user_input
        end
      end
    end
  end
end
