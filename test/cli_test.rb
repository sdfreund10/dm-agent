# frozen_string_literal: true

require "test_helper"
require "lib/models/world"
require "lib/models/character"
require "lib/models/campaign"
require "cli/campaign_selection"
require "cli"

class CLITest < Minitest::Test
  def setup
    @stdin = $stdin
    @stdout = $stdout
  end

  def teardown
    $stdin = @stdin
    $stdout = @stdout
  end

  def test_run_prints_selected_campaign_and_character_when_CampaignSelection_stubbed
    campaign = build_campaign(name: "Stubbed Campaign")
    character = Character.new(
      name: "New Character",
      dnd_class: "Fighter",
      species: "Human",
      level: "3",
      backstory: "",
      campaigns: []
    )
    stub_result = Struct.new(:selected_campaign, :selected_character).new(campaign, character)

    $stdout = StringIO.new
    CLI::CampaignSelection.stub :run, stub_result do
      CLI::Main.run
    end
    output = $stdout.string

    assert_includes output, "Campaign selected: Stubbed Campaign"
    assert_includes output, "Character selected: New Character"
  end
end
