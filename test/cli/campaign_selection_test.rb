# frozen_string_literal: true

require "test_helper"
require "lib/models/world"
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

  def build_character(campaigns: [])
    Character.new(
      name: "Test Hero",
      dnd_class: "Fighter",
      species: "Human",
      level: "3",
      backstory: "",
      campaigns: campaigns
    )
  end

  def test_run_returns_self_and_sets_selected_character_and_campaign
    campaign = build_campaign(name: "My Campaign")
    character = build_character(campaigns: [campaign])
    $stdin = StringIO.new("1\n1\n")
    $stdout = StringIO.new

    result = nil
    Character.stub :all, [character] do
      result = CLI::CampaignSelection.run
    end

    assert_equal character, result.selected_character
    assert_equal campaign, result.selected_campaign
  end

  def test_selecting_new_character_uses_CharacterCreation_run_stub
    created_character = build_character(campaigns: [])
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
