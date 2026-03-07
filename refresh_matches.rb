require_relative 'setup'

event = DB[:events].where(code: ENV['YEAR'] + ENV['EVENT']).first
unless event
    puts "Event #{ENV['EVENT']} not found in the database!"
    exit
end
all_matches = DB[:matches].where(event_id: event[:id]).order(:time).all
now = Time.now
matches = all_matches.select { |m| m[:time] <= now }.last(2) + all_matches.select { |m| m[:time] > now }.first(2)

puts matches.map { |m| m[:code] }
exit

matches.each do |match|
    match_response = Excon.get("https://api.statbotics.io/v3/match/#{match[:key]}")
    match = JSON.parse(match_response.body)
    puts "got match #{match['key']}"

    DB[:matches].where(code: match['key']).update(time: match['time'], predicted_time: match['predicted_time'], status: match['status'], prediction: match['pred'].to_json, real_results: match['result'].to_json, event_id: event[:id])

    team_match_response = Excon.get("https://api.statbotics.io/v3/team_matches?match=#{match['key']}")
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