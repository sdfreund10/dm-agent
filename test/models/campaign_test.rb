# frozen_string_literal: true

require "test_helper"
require "lib/models/campaign"
require "lib/models/campaign_chat"

class CampaignTest < Minitest::Test
  def test_campaign_can_serialize_to_hash
    campaign = build_campaign
    assert_includes(campaign.to_hash, :name)
    assert_equal(campaign.name, campaign.to_hash[:name])
  end

  def test_save_writes_to_file
    campaign = build_campaign
    campaign.save
    assert(File.exist?(campaign.file_name))
    assert_equal(campaign.to_json, File.read(campaign.file_name))
  end

  def test_create_writes_to_file
    campaign = Campaign.create(build_campaign.to_hash)
    assert(File.exist?(campaign.file_name))
    assert_equal(campaign.to_json, File.read(campaign.file_name))
  end

  def test_campaign_chats_returns_chats_for_campaign
    campaign = build_campaign
    campaign.save
    other_campaign = build_campaign(id: SecureRandom.uuid)
    other_campaign.save
    chat1 = CampaignChat.new(campaign_id: campaign.id, messages: [])
    chat1.save
    chat2 = CampaignChat.new(campaign_id: campaign.id, messages: [])
    chat2.save
    _other_chat = CampaignChat.new(campaign_id: other_campaign.id, messages: [])
    _other_chat.save

    result = campaign.campaign_chats
    assert_equal 2, result.size
    assert_includes result.map(&:id), chat1.id
    assert_includes result.map(&:id), chat2.id
  end
end
