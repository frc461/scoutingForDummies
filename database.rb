require 'sinatra'
require 'sequel'

DB = Sequel.connect('sqlite://test.sqlite3')

get "/" do
  "buzz off"
  @teams = DB.from(:teams)
  erb :database_index
end