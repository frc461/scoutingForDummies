require 'sinatra'
require_relative 'setup'

configure :production do
  set :host_authorization, { permitted_hosts: [] }
end

get "/" do
  @teams = DB.from(:teams)
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
  erb :'events/show'
end