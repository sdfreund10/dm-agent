require "json"
require "lib/agents/backstory_agent"

class World
  attr_accessor :campaign, :backstory, :characters, :events, :notes, :plot, :themes

  def initialize(campaign:, backstory: nil, characters: nil, events: nil, notes: nil, plot: nil, themes: nil)
    @campaign = campaign
    @backstory = backstory
    @characters = characters
    @events = events
    @notes = notes
    @plot = plot
    @themes = themes
  end

  def to_hash
    {
      backstory: backstory,
      characters: characters,
      events: events,
      notes: notes,
      plot: plot,
      themes: themes
    }
  end

  def to_json
    to_hash.to_json
  end

  def generate_backstory
    return self if backstory

    Agents::BackstoryAgent.new(world: self).generate_backstory
    self
  end

  def save
    campaign.save
  end
end
