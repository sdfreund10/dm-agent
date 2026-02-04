# frozen_string_literal: true

require "lib/models/campaign"

module TestSupport
  module Factories
    DEFAULT_CAMPAIGN_ATTRS = { name: "Test Campaign" }.freeze

    def build_campaign(overrides = {})
      Campaign.new(**DEFAULT_CAMPAIGN_ATTRS.merge(overrides))
    end
  end
end
