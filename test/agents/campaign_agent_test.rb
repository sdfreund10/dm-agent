# frozen_string_literal: true

require "test_helper"
require "lib/models/log"
require "lib/agents/campaign_agent"

class CampaignAgentTest < Minitest::Test
  def test_initialize_sets_campaign_player_character_and_log
    campaign = build_campaign(name: "Test Campaign")
    character = build_character(name: "Hero")

    agent = CampaignAgent.new(campaign, character)

    assert_equal campaign, agent.campaign
    assert_equal character, agent.player_character
    assert_equal campaign.id, agent.log.campaign_id
    assert_equal character.id, agent.log.player_character_id
    assert_equal [], agent.log.messages
  end

  def test_run_adds_user_and_system_messages_to_log_and_returns_content
    campaign = build_campaign
    character = build_character
    agent = CampaignAgent.new(campaign, character)
    $stdout = StringIO.new

    content = agent.run(message: "I look around the room.")

    assert_equal TestSupport::LLMStub::DEFAULT_LORE_CONTENT, content
    assert_equal 2, agent.log.messages.size
    assert_equal "user", agent.log.messages[0][:type]
    assert_equal "I look around the room.", agent.log.messages[0][:message]
    assert_equal "system", agent.log.messages[1][:type]
    assert_equal content, agent.log.messages[1][:message]
  end

  def test_start_adds_system_message_to_log_and_returns_content
    campaign = build_campaign
    character = build_character
    agent = CampaignAgent.new(campaign, character)
    $stdout = StringIO.new

    content = agent.start!

    assert_equal TestSupport::LLMStub::DEFAULT_LORE_CONTENT, content
    assert_equal 1, agent.log.messages.size
    assert_equal "system", agent.log.messages[0][:type]
    assert_equal content, agent.log.messages[0][:message]
  end

  def test_starting_prompt_includes_campaign_and_character_details
    campaign = build_campaign(name: "Epic Quest", genre: "Heroic Epic")
    character = build_character(name: "Aragorn", backstory: "A ranger from the north")

    agent = CampaignAgent.new(campaign, character)
    prompt = agent.starting_prompt

    assert_includes prompt, "Epic Quest"
    assert_includes prompt, "Heroic Epic"
    assert_includes prompt, "Aragorn"
    assert_includes prompt, "A ranger from the north"
    assert_includes prompt, "inciting incident"
    assert_includes prompt, "Character Details"
  end
end
