require 'dotenv'
Dotenv.load('.env', 'env')

require 'excon'
require 'json'
require 'sequel'

DB = Sequel.connect('sqlite://test.sqlite3')