$LOAD_PATH.unshift(File.expand_path(".", __dir__))
require "lib/models/campaign"

class CLI
  def self.run
    new.run
  end

  def run
    welcome_message
    show_main_menu
  end

  private

  def welcome_message
    puts "\n" + "=" * 60
    puts "  Welcome! I am your AI Dungeon Master!"
    puts "=" * 60
    puts "\n"
  end

  def show_main_menu
    available_campaigns = Campaign.all

    if available_campaigns.empty?
      puts "No existing campaigns found."
      puts "\nWould you like to create a new campaign? (y/n)"
      choice = gets.chomp.downcase

      if choice == 'y' || choice == 'yes'
        create_new_campaign
      else
        puts "Goodbye!"
        exit
      end
    else
      puts "Available campaigns:"
      available_campaigns.each_with_index do |campaign, index|
        puts "  #{index + 1}. #{campaign.name}"
      end

      puts "\nWhat would you like to do?"
      puts "  1. Play an existing campaign"
      puts "  2. Create a new campaign"
      puts "\nEnter your choice (1 or 2): "

      choice = gets.chomp.strip

      case choice
      when "1"
        play_existing_campaign(available_campaigns)
      when "2"
        create_new_campaign
      else
        puts "Invalid choice. Please enter 1 or 2."
        show_main_menu
      end
    end
  end

  def play_existing_campaign(campaigns)
    puts "\nSelect a campaign to play:"
    campaigns.each_with_index do |campaign, index|
      puts "  #{index + 1}. #{campaign.name}"
    end
    puts "\nEnter the number of the campaign: "

    choice = gets.chomp.to_i

    if choice.between?(1, campaigns.length)
      selected_campaign = campaigns[choice - 1]
      puts "\nLoading campaign: #{selected_campaign.name}"
      # TODO: Implement campaign play logic
      puts "Campaign loaded! (Play functionality coming soon)"
    else
      puts "Invalid selection."
      play_existing_campaign(campaigns)
    end
  end

  def create_new_campaign
    puts "\nCreating a new campaign..."
    # TODO: Implement campaign creation logic
    puts "Campaign creation coming soon!"
  end
end

# Run the CLI if this file is executed directly
if __FILE__ == $0
  CLI.run
end
