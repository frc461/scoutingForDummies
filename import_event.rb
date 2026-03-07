require_relative 'setup'

# event_response = Excon.get("https://api.statbotics.io/v3/event/#{ENV['YEAR']}#{ENV['EVENT']}")
# event_data = JSON.parse(event_response.body)

# event = DB[:events].where(code: "#{ENV['YEAR']}#{ENV['EVENT']}").first
# unless event
#     puts "Event #{ENV['YEAR']}#{ENV['EVENT']} not found in the database! Creating..."
#     begin
#         DB[:events].insert(name: event_data['name'], code: event_data['key'])
#         event = DB[:events].where(code: "#{ENV['YEAR']}#{ENV['EVENT']}").first
#     rescue => e
#         puts "Problem with creating event #{ENV['YEAR']}#{ENV['EVENT']}!"
#         binding.irb
#     end
# end

# teams_response = Excon.get("https://api.statbotics.io/v3/team_events?event=#{ENV['YEAR']}#{ENV['EVENT']}")
# begin
# teams = JSON.parse(teams_response.body)
# rescue => e
#     puts "Problem with fetching teams for event #{ENV['YEAR']}#{ENV['EVENT']}!"
#     binding.irb
# end

# teams.each do |team|
#     db_team = DB[:teams].where(number: team['team']).first
#     unless db_team
#         puts "Team #{team['team']} not found in the database! Creating..."
#         team_response = Excon.get("https://api.statbotics.io/v3/team/#{team['team']}")
#         team_data = JSON.parse(team_response.body)
#         begin
#         DB[:teams].insert(name: team_data['name'], number: team_data['team'], play_style: '?')
#         db_team = DB[:teams].where(number: team['team']).first
#         rescue => e
#             puts "Problem with creating team #{team['team']}!"
#             binding.irb
#         end
#     end
#     unless DB[:attendance].where(team_id: db_team[:id], event_id: event[:id]).empty?
#         puts "Team #{team['team']} already marked as attending #{event_data['name']}!"
#         next
#     end
#     begin
#         DB[:attendance].insert(team_id: db_team[:id], event_id: event[:id])
#     rescue => e
#         puts "Problem with attendance for team #{team['team']} at event #{event_data['name']}!"
#         next
#     end
# end

matches_response = Excon.get("https://api.statbotics.io/v3/matches?event=#{ENV['YEAR']}#{ENV['EVENT']}")
if matches_response.status != 200
    puts "Problem with fetching matches for event #{ENV['YEAR']}#{ENV['EVENT']}!"
    binding.irb
end
matches = JSON.parse(matches_response.body)

matches.each do |match|
    unless DB[:matches].where(code: match['key']).empty?
        puts "Match #{match['key']} already exists in the database!"
        DB[:matches].where(code: match['key']).update(time: match['time'], predicted_time: match['predicted_time'], status: match['status'], prediction: match['pred'].to_json, real_results: match['result'].to_json, event_id: ENV['EVENT'])
        next
    end
    begin
        p match['key']
        DB[:matches].insert(code: match['key'], time: match['time'], predicted_time: match['predicted_time'], status: match['status'], prediction: match['pred'].to_json, real_results: match['result'].to_json, event_id: ENV['EVENT'])
    rescue => e
        puts "Problem with #{match}!"
        binding.irb
    end

    team_match_response = Excon.get("https://api.statbotics.io/v3/team_matches?match=#{match['key']}")
    if team_match_response.status != 200
        puts "Problem with fetching team matches for match #{match['key']}!"
        binding.irb
    end
    begin
        team_matches = JSON.parse(team_match_response.body)
    rescue => e
        puts "Problem with fetching team matches for match #{match['key']}!"
        binding.irb
    end
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

