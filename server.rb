require 'sinatra'
require_relative 'setup'

configure :production do
  set :host_authorization, { permitted_hosts: [] }
end

get "/" do
  @matches = DB[:matches].join(:plays, match_code: :code).where(Sequel[:plays][:team_number] => ENV['TEAM']).select_all(:matches).order(:time).distinct
  @next_match = @matches.where(status: 'Upcoming').first
  if @next_match
    @next_match_plays = DB[:plays].where(match_code: @next_match[:code]).join(:teams, number: :team_number).select(Sequel[:plays][:team_number], Sequel[:plays][:alliance], Sequel[:plays][:epa], Sequel[:teams][:name])
    @next_match_prediction = JSON.parse(@next_match[:prediction])
  end
  erb :index
end

get '/teams' do
  @teams = DB.from(:teams)
  erb :'teams/index'
end

get '/teams/:number' do
  @team = DB.from(:teams).where(number: params[:number]).first
  @notes = DB.from(:notes).where(team_number: params[:number])
  @photos = DB.from(:photos).where(team_number: params[:number])
  @matches = DB[:plays].where(team_number: params[:number]).join(:matches, code: :match_code).select(Sequel[:matches][:code], Sequel[:matches][:time], Sequel[:matches][:status], Sequel[:matches][:prediction], Sequel[:matches][:real_results], Sequel[:plays][:alliance], Sequel[:plays][:epa]).order(:time)
  erb :'teams/show'
end

get "/notes/new" do
  @team_number = params['team_number']
  erb :'notes/new'
end

post "/note" do
  DB[:notes].insert(team_number: params['team_number'], content: params['content'])  
  if params["team_number"].downcase == "boom" && params["content"].downcase == "boom"
    erb :BOOM
  else
    redirect "/"
  end
end

get "/photos/new" do
  @team_number = params['team_number']
  erb :'photos/new'
end

post "/photo" do
  filename = params[:file][:filename]
  file = params[:file][:tempfile]

  File.open("./public/uploads/#{filename}", 'wb') do |f|
    f.write(file.read)
  end

  DB[:photos].insert(team_number: params['team_number'], filename: filename)  
  redirect "/"
end

get "/events" do
  @events = DB[:events].all
  erb :'events/index'
end

get "/events/:code" do
  @event = DB[:events].where(code: params['code']).first
  @teams = DB[:attendance].where(event_id: @event[:id]).join(:teams, id: :team_id).select(Sequel[:teams][:number], Sequel[:teams][:name])
  @matches = DB[:matches].where(event_id: @event[:id]).order(:time).all
  erb :'events/show'
end

get '/matches/:code' do
  @match = DB[:matches].where(code: params[:code]).first
  @plays = DB[:plays].where(match_code: params[:code]).join(:teams, number: :team_number).select(Sequel[:plays][:team_number], Sequel[:plays][:alliance], Sequel[:plays][:epa], Sequel[:teams][:name])
  erb :'matches/show'
end