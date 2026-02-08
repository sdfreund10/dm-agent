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
      puts "--------------------------------"
      starting_message = @campaign_agent.start!
      puts starting_message
      puts "--------------------------------"

      while true
        message = get_input("What would you like to do? (type 'exit' to end the campaign)")
        if message.downcase == "exit"
          break
        else
          response = @campaign_agent.run(message: message)
          puts "--------------------------------"
          puts response
          puts "--------------------------------"
        end
      end
    end
  end
end
