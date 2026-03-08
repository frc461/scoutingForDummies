require_relative 'setup'

event = DB[:events].where(code: ENV['YEAR'] + ENV['EVENT']).first
unless event
    puts "Event #{ENV['EVENT']} not found in the database!"
    exit
end

puts "Found event, starting to loop"
while true
  puts "looping"
  last_match = DB[:matches].where(event_id: event[:id], status: 'Upcoming').order('time').last
  puts "last unplayed match #{last_match[:code]}"
all_matches = DB[:matches].where(event_id: event[:id]).order(:time).all
now = Time.now
matches = ( all_matches.select { |m| m[:time] > now }.first(2) + all_matches.select { |m| m[:time] >= last_match[:time] && m[:time] < now } ).uniq

puts matches.map { |m| m[:code] }

matches.each do |match|
    match_response = Excon.get("https://api.statbotics.io/v3/match/#{match[:code]}")
    if match_response.status != 200
        puts "Problem with fetching match #{match[:key]}!"
        next
    end
    match = JSON.parse(match_response.body)
    puts "got match #{match['key']} #{[match['time']]}"

    DB[:matches].where(code: match['key']).update(time: match['time'], predicted_time: match['predicted_time'], status: match['status'], prediction: match['pred'].to_json, real_results: match['result'].to_json, event_id: event[:id])

    team_match_response = Excon.get("https://api.statbotics.io/v3/team_matches?match=#{match['key']}")
    if team_match_response.status != 200
        puts "Problem with fetching team matches for match #{match['key']}!"
        next
    end
    team_matches = JSON.parse(team_match_response.body)
    team_matches.each do |team_match|
        team = DB[:teams].where(number: team_match['team']).first
        unless team
            puts "Team #{team_match['team']} not found in the database for match #{match['key']}!"
            next
        end
        play = DB[:plays].where(team_number: team[:number], match_code: match['key']).first
        if play
            DB[:plays].where(id: play[:id]).update(alliance: team_match['alliance'], epa: team_match['epa'].to_json)
        else
            DB[:plays].insert(team_number: team[:number], match_code: match['key'], alliance: team_match['alliance'], epa: team_match['epa'].to_json)
        end
    end
end
puts "done with run"
sleep 60*3
end
