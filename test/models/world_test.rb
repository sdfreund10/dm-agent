# frozen_string_literal: true

require "test_helper"
require "lib/models/campaign"
require "lib/models/world"

class WorldTest < Minitest::Test
  def test_world_serializes_to_hash
    campaign = build_campaign
    world = ::World.new(campaign: campaign)
    assert_equal(
      {
        backstory: nil,
        characters: nil,
        events: nil,
        notes: nil,
        plot: nil,
        themes: nil
      },
      world.to_hash
    )
  end

  def test_world_can_generate_backstory
    campaign = build_campaign
    world = ::World.new(campaign: campaign)
    world.generate_backstory
    puts world.to_json
    refute_nil(world.backstory)
    refute_nil(world.characters)
    refute_nil(world.plot)
  end

  def test_world_does_not_generate_backstory_if_already_generated
    campaign = build_campaign
    world = ::World.new(campaign: campaign, backstory: "Test Backstory")
    assert_equal("Test Backstory", world.backstory)
    world.generate_backstory
    assert_equal("Test Backstory", world.backstory)
  end

  def test_save_writes_to_file
    campaign = build_campaign
    world = campaign.world
    world.save
    assert(File.exist?(campaign.file_name))
  end
end
