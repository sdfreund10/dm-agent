# frozen_string_literal: true

require "test_helper"
require "lib/models/campaign_chat"

class CampaignChatTest < Minitest::Test
  def test_last_message_at_returns_nil_when_messages_empty
    chat = CampaignChat.new(campaign_id: "c1", player_character_id: "p1", messages: [])
    assert_nil chat.last_message_at
  end

  def test_last_message_at_returns_last_message_timestamp_when_multiple_messages
    t1 = Time.at(100)
    t2 = Time.at(200)
    messages = [
      { type: "user", message_content: "a", timestamp: t1 },
      { type: "system", message_content: "b", timestamp: t2 }
    ]
    chat = CampaignChat.new(campaign_id: "c1", player_character_id: "p1", messages: messages)
    assert_equal t2, chat.last_message_at
  end

  def test_find_by_returns_nil_when_both_arguments_empty
    assert_nil CampaignChat.find_by(campaign_id: nil, player_character_id: nil)
  end

  def test_find_by_matches_by_campaign_id
    chat_a = CampaignChat.new(id: 'AA',campaign_id: "cid-1", player_character_id: "pc-1", messages: [])
    chat_b = CampaignChat.new(id: 'BB',campaign_id: "cid-2", player_character_id: "pc-2", messages: [])
    chat_a.save
    chat_b.save

    result = CampaignChat.find_by(campaign_id: "cid-1")
    refute_nil result
    assert_equal "cid-1", result.campaign_id
    assert_equal "pc-1", result.player_character_id
  end

  def test_find_by_matches_by_player_character_id
    chat_a = CampaignChat.new(campaign_id: "cid-1", player_character_id: "pc-1", messages: [])
    chat_b = CampaignChat.new(campaign_id: "cid-2", player_character_id: "pc-2", messages: [])
    chat_a.save
    chat_b.save

    result = CampaignChat.find_by(player_character_id: "pc-2")
    refute_nil result
    assert_equal "cid-2", result.campaign_id
    assert_equal "pc-2", result.player_character_id
  end

  def test_find_by_returns_nil_when_no_matches
    result = CampaignChat.find_by(campaign_id: "nonexistent", player_character_id: "also-missing")
    assert_nil result
  end

  def test_find_by_returns_first_match_when_multiple_valid_matches
    first_chat = CampaignChat.new(campaign_id: "c1", player_character_id: "p1", messages: [])
    second_chat = CampaignChat.new(campaign_id: "c1", player_character_id: "p1", messages: [])
    first_chat.save
    second_chat.save

    CampaignChat.stub :all, [first_chat, second_chat] do
      result = CampaignChat.find_by(campaign_id: "c1", player_character_id: "p1")
      assert_equal first_chat.id, result.id
    end
  end

  def test_for_campaign_returns_only_chats_for_that_campaign
    cid1 = SecureRandom.uuid
    cid2 = SecureRandom.uuid
    chat_a = CampaignChat.new(campaign_id: cid1, player_character_id: "pc-1", messages: [])
    chat_b = CampaignChat.new(campaign_id: cid2, player_character_id: "pc-2", messages: [])
    chat_c = CampaignChat.new(campaign_id: cid1, player_character_id: "pc-2", messages: [])
    chat_a.save
    chat_b.save
    chat_c.save

    result = CampaignChat.for_campaign(cid1)
    assert_equal 2, result.size
    assert_includes result.map(&:id), chat_a.id
    assert_includes result.map(&:id), chat_c.id
    refute_includes result.map(&:id), chat_b.id
  end
end
