require "fileutils"
require "json"
require "debug"

module FileSaveable
  def save
    File.write(file_name, to_json)
    self
  end

  def file_name
    "#{self.class.data_location}/#{id}.json"
  end

  def self.included(model)
    model.extend(ClassMethods)
    FileUtils.mkdir_p(model.data_location)
  end

  module ClassMethods
    def storage_key(name)
      @storage_key = name
      FileUtils.mkdir_p(data_location)
    end

    def _storage_key
      @storage_key || self.name.downcase
    end

    def data_location
      if ENV["APP_ENV"] == "test"
        File.expand_path("../../../data/test/#{_storage_key}", __dir__)
      else
        File.expand_path("../../../data/#{_storage_key}", __dir__)
      end
    end

    def all
      file_names = Dir.glob("#{data_location}/*.json")
      file_names.map do |file_name|
        _load(file_name)
      end
    end

    def find(id)
      file_name = "#{data_location}/#{id}.json"

      if File.exist?(file_name)
        _load(file_name)
      else
        nil
      end
    end

    def _load(file_name)
      record_data = JSON.parse(File.read(file_name)).transform_keys(&:to_sym)
      new(**record_data)
    end

    def delete_all
      FileUtils.rm_f Dir.glob("#{data_location}/*")
    end

    def create(attributes)
      new(**attributes).save
    end
  end
end
