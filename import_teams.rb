require_relative 'setup'

response = Excon.get("https://api.statbotics.io/v3/team_years?year=#{ENV['YEAR']}&district=fin")
teams = JSON.parse(response.body)

teams.each do |team|
    unless DB[:teams].where(number: team['number']).empty?
        puts "Team #{team['name']} already exists in the database!"
        DB[:teams].where(number: team['number']).update(name: team['name'])
        next
    end
    begin
        p team['name']
        DB[:teams].insert(name: team['name'], number: team['team'], play_style: '?')
    rescue 
        puts "Problem with #{team}!"
    end
end

# teams = DB.from(:teams)
# teams.each do |team|
#   p team
  
#   notes = DB.from(:notes).where(team_number: team[:number])
#   notes.each do |note|
#     p note
#   end
# end