require 'sinatra'
require 'json'

get '/hi' do
  "Hello!"
end

get "/poi/:type" do
  content_type :json
  puts "params: #{params}"
  puts "query string: #{request.query_string}"

  {
    "type" => params['type'],
    "center_lat" => params[:center_lat],
    "center_lon" => params[:center_lon],
    "radius" => params[:radius]
   }.to_json
end
