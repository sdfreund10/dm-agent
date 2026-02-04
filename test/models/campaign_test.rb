# frozen_string_literal: true

require "test_helper"
require "lib/models/campaign"

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
end
