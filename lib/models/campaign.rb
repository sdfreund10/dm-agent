require "securerandom"
require "json"

# File-backed ORM
#  - Each record is a JSON named like <model-name>-<uuid>.json
#
class Campaign
  attr_reader :id, :world
  attr_accessor :name

  def initialize(id: SecureRandom.uuid, name:, themes:[],world_params: {})
    @id = id
    @name = name
    @world = World.new(campaign: self, **world_params)
  end

  def set_up
    world.generate_backstory(themes: themes)
  end


  def save
    File.write(file_name, to_json)
  end

  def file_name
    "#{self.class.data_location}/#{id}.json"
  end

  def to_hash
    {
      id: id,
      name: name,
      world: world.to_hash,
      themes: themes
    }
  end

  def to_json
    to_hash.to_json
  end

  # Class methods
  def self.data_location
    if ENV["APP_ENV"] == "test"
      File.expand_path("../../data/test/campaigns", __dir__)
    else
      File.expand_path("../../data/campaigns", __dir__)
    end
  end

  def self.all
    file_names = Dir.glob("#{data_location}/*.json")
    file_names.map do |file_name|
      new(JSON.parse(File.read(file_name)))
    end
  end

  def self.find(id)
    file_name = "#{data_location}/#{id}.json"

    if File.exist?(file_name)
      new(JSON.parse(File.read(file_name)))
    else
      nil
    end
  end

  def self.delete_all
    FileUtils.rm_f Dir.glob("#{data_location}/*")
  end
end
