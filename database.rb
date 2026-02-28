require 'sinatra'
require 'sequel'

DB = Sequel.connect('sqlite://test.sqlite3')

get "/" do
  @teams = DB.from(:teams)
  erb :database_index
end

get "/notes/new" do
  erb :new_note
end
get "/photos/new" do
  erb :new_photo
end
post "/note" do
  DB[:notes].insert(team_number: params['team_number'], content: params['content'])  
  if params["team_number"].downcase == "boom" && params["content"].downcase == "boom"
    erb :BOOM
  else
    redirect "/"
  end
end

post "/photo" do
  filename = params[:file][:filename]
  file = params[:file][:tempfile]

  File.open("./public/#{filename}", 'wb') do |f|
    f.write(file.read)
  end

  DB[:photos].insert(team_number: params['team_number'], filename: filename)  
  redirect "/"
end