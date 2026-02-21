require 'sequel'
require 'excon'
require 'json'

DB = Sequel.connect('sqlite://test.sqlite3')

#DB.run("insert into teams values (null, 'West Side Robotics', '467','defense')")

# # DB.run("insert into notes values (null, 'I like Cheeseburger', '67')")

# teams = DB.from(:teams)

# teams.each do |team|
#   p team
  
#   notes = DB.from(:notes).where(team_number: team[:number])
#   notes.each do |note|
#     p note
#   end
# end

# response = Excon.get('https://api.statbotics.io/v3/teams?district=fin')
# teams = JSON.parse(response.body)

# teams.each do |team|
#     # p team['name']
#     # DB["insert into teams values (null, ?, ?, '' )", team['name'], team['number']]
#     begin
#         DB[:teams].insert(name: team['name'], number: team['team'], play_style: '?')
#     rescue 
#         puts "Problem with #{team}!"
#     end
# end

teams = DB.from(:teams)
teams.each do |team|
  p team
  
  notes = DB.from(:notes).where(team_number: team[:number])
  notes.each do |note|
    p note
  end
end