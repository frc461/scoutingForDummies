require_relative 'setup'

response = Excon.get("https://api.statbotics.io/v3/events?year=#{ENV['YEAR']}&district=fin")
events = JSON.parse(response.body)

events.each do |event|
    unless DB[:events].where(code: event['key']).empty?
        puts "Event #{event['name']} already exists in the database!"
        DB[:events].where(code: event['key']).update(name: event['name'])
        next
    end
    begin
        p event['name']
        DB[:events].insert(name: event['name'], code: event['key'])
    rescue => e
        puts "Problem with #{event}!"
        binding.irb
    end
end

events.each do |event|
    event_teams_response = Excon.get("https://api.statbotics.io/v3/team_events?event=#{event['key']}")
    event_teams = JSON.parse(event_teams_response.body)
    event_teams.each do |team|
        team_id = DB[:teams].where(number: team['team']).get(:id)
        event_id = DB[:events].where(code: event['key']).get(:id)
        unless DB[:attendance].where(team_id: team_id, event_id: event_id).empty?
            puts "Team #{team['team']} already marked as attending #{event['name']}!"
            next
        end
        begin
            DB[:attendance].insert(team_id: team_id, event_id: event_id)
        rescue => e
            puts "Problem with attendance for team #{team['team']} at event #{event['name']}!"
            next
        end
    end
end

