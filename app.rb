# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path(__dir__))
require "sinatra"
require "sinatra/reloader" if development?
require "kramdown"
require "lib/models/character"
require "lib/models/campaign"
require "lib/models/campaign_chat"

class DmAgentApp < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  set :views, File.expand_path("views", __dir__)
  set :public_folder, File.expand_path("public", __dir__)
  set :method_override, true

  helpers do
    def h(text)
      return "" if text.nil?
      Rack::Utils.escape_html(text)
    end

    def markdown(text)
      return "" if text.nil? || text.to_s.strip.empty?
      Kramdown::Document.new(text.to_s).to_html
    end

    def time_ago_in_words(from_time)
      return "" if from_time.nil?
      secs = (Time.now - from_time).to_i
      return "just now" if secs < 60
      return "1 minute" if secs < 120
      return "#{secs / 60} minutes" if secs < 3600
      return "1 hour" if secs < 7200
      return "#{secs / 3600} hours" if secs < 86_400
      return "1 day" if secs < 172_800
      "#{secs / 86_400} days"
    end
  end

  get "/" do
    @characters = Character.all
    @campaigns = Campaign.all
    erb :index
  end

  get "/characters/new" do
    @character_classes = Character::CLASSES.keys
    @species = %w[Human Elf Dwarf Halfling Gnome Half-Elf Half-Orc Tiefling Aasimar Dragonborn]
    @levels = %w[3 6 9 12]
    erb :"characters/new"
  end

  post "/characters" do
    backstory = params[:backstory].to_s.strip
    character = Character.new(
      name: params[:name],
      dnd_class: params[:dnd_class],
      species: params[:species],
      level: params[:level],
      backstory: backstory.empty? ? nil : backstory
    )
    character.generate_backstory if character.backstory.nil?
    character.save
    redirect to("/"), 303
  end

  get "/characters/:id" do
    @character = Character.find(params[:id])
    halt 404, erb(:"errors/404") unless @character
    erb :"characters/show"
  end

  delete "/characters/:id" do
    character = Character.find(params[:id])
    character&.delete
    redirect to("/"), 303
  end

  get "/campaigns/new" do
    @genres = Campaign::GENRES
    @tones = Campaign::TONES
    @stakes = %w[Low Medium High]
    erb :"campaigns/new"
  end

  post "/campaigns" do
    campaign = Campaign.generate(
      genre: params[:genre],
      tone: params[:tone],
      stakes: params[:stakes]
    )
    redirect to("/campaigns/#{campaign.id}"), 303
  end

  get "/campaigns/:id" do
    @campaign = Campaign.find(params[:id])
    halt 404, erb(:"errors/404") unless @campaign
    erb :"campaigns/show"
  end

  delete "/campaigns/:id" do
    campaign = Campaign.find(params[:id])
    campaign&.delete
    redirect to("/"), 303
  end

  get "/campaigns/:id/playthroughs/new" do
    @campaign = Campaign.find(params[:id])
    halt 404, erb(:"errors/404") unless @campaign
    @characters = Character.all
    erb :"playthroughs/select_character"
  end

  post "/campaigns/:id/playthroughs" do
    @campaign = Campaign.find(params[:id])
    halt 404, erb(:"errors/404") unless @campaign
    character = Character.find(params[:character_id])
    halt 404, erb(:"errors/404") unless character
    chat = CampaignChat.new(campaign_id: @campaign.id, player_character_id: character.id, messages: [])
    chat.save
    redirect to("/playthroughs/#{chat.id}"), 303
  end

  get "/playthroughs/:id" do
    @playthrough = CampaignChat.find(params[:id])
    halt 404, erb(:"errors/404") unless @playthrough
    erb :"playthroughs/show"
  end

  get "/playthroughs/:id/messages" do
    @playthrough = CampaignChat.find(params[:id])
    halt 404, erb(:"errors/404") unless @playthrough
    @playthrough.start! unless @playthrough.started?
    erb :"playthroughs/messages", layout: false
  end

  post "/playthroughs/:id/messages" do
    @playthrough = CampaignChat.find(params[:id])
    halt 404, erb(:"errors/404") unless @playthrough
    user_message = (params[:message] || "").to_s.strip
    if user_message.empty?
      status 422
      content_type "text/vnd.turbo-stream.html"
      return erb(:"playthroughs/exchange", layout: false)
    end
    @playthrough.start! unless @playthrough.started?
    @playthrough.chat!(user_message: user_message)
    content_type "text/vnd.turbo-stream.html"
    html = erb :"playthroughs/exchange", layout: false
    puts html
    html
  end
end
