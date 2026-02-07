# frozen_string_literal: true

require "lib/models/campaign"

module TestSupport
  module Factories
    DEFAULT_CAMPAIGN_ATTRS = {
      id: SecureRandom.uuid,
      name: "Test Campaign",
      genre: "Heroic Epic",
      tone: "Lighthearted",
      world_info: "A world of magic and adventure",
      inciting_incident: "The party is tasked with finding the lost artifact of the gods",
      end_goal: "The party must defeat the evil sorcerer and save the world",
      primary_antagonist: "The evil sorcerer",
      npcs: ["The party's mentor", "The party's guide"],
      locations: ["The party's home", "The party's destination"],
      rumors: ["There is a hidden city of elves", "There is a hidden city of dwarves"]
    }.freeze

    def build_campaign(overrides = {})
      Campaign.new(**DEFAULT_CAMPAIGN_ATTRS.merge(overrides))
    end

    DEFAULT_CHARACTER_ATTRS = {
      name: "Test Hero",
      dnd_class: "Fighter",
      species: "Human",
      level: "3",
      backstory: "",
      campaign_ids: []
    }.freeze

    def build_character(overrides = {})
      Character.new(
        **DEFAULT_CHARACTER_ATTRS.merge(overrides)
      )
    end
  end
end
