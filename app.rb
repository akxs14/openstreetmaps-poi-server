require 'sinatra'
require 'json'
require_relative 'poi_manager'

db = POIManager.new

get '/hi' do
  "Hello!"
end

get "/poi/:type" do
  content_type :json
  { params['type'] => db.get_pois(params[:type]) }.to_json
end
