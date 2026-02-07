# frozen_string_literal: true

require "test_helper"
require "lib/models/character"
require "lib/models/campaign"
require "cli/campaign_selection"

class CampaignSelectionTest < Minitest::Test
  def setup
    @stdin = $stdin
    @stdout = $stdout
  end

  def teardown
    $stdin = @stdin
    $stdout = @stdout
  end

  def test_run_returns_self_and_sets_selected_character_and_campaign
    campaign = build_campaign(name: "My Campaign")
    character = build_character(campaign_ids: [campaign.id])
    $stdin = StringIO.new("1\n1\n")
    $stdout = StringIO.new

    result = nil
    Character.stub :all, [character] do
      Campaign.stub :all, [campaign] do
        Campaign.stub :find, campaign do
          result = CLI::CampaignSelection.run
        end
      end
    end

    assert_equal character, result.selected_character
    assert_equal campaign, result.selected_campaign
  end

  def test_selecting_new_character_uses_CharacterCreation_run
    created_character = build_character(campaign_ids: [])
    created_campaign = build_campaign(name: "New Campaign")
    $stdin = StringIO.new("1\n1\n") # option 1 = New Character, then option 1 = New Campaign
    $stdout = StringIO.new

    result = nil
    Character.stub :all, [] do
      CLI::CharacterCreation.stub :run, created_character do
        CLI::CampaignCreation.stub :run, created_campaign do
          result = CLI::CampaignSelection.run
        end
      end
    end

    assert_equal created_character, result.selected_character
    assert_equal created_campaign, result.selected_campaign
  end
end
