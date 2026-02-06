require "json"
require "lib/agents/backstory_agent"

class World
  attr_accessor :campaign, :backstory, :npcs, :events, :notes, :plot

  def initialize(campaign:, backstory: nil, npcs: nil, events: nil, notes: nil, plot: nil)
    @campaign = campaign
    @backstory = backstory
    @npcs = npcs
    @events = events
    @notes = notes
    @plot = plot
  end

  def to_hash
    {
      backstory: backstory,
      npcs: npcs,
      events: events,
      notes: notes,
      plot: plot
    }
  end

  def to_json
    to_hash.to_json
  end

  def generate_backstory
    return self if backstory

    BackstoryAgent.new(world: self).generate_backstory
    self
  end

  def save
    campaign.save
  end
end
