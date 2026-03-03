require_relative 'setup'

response = Excon.get("https://api.statbotics.io/v3/matches?event=#{ENV['YEAR']}#{ENV['EVENT']}")
matches = JSON.parse(response.body)

matches.each do |matches|
    unless DB[:matches].where(code: match['key']).empty?
        puts "Match #{match['name']} already exists in the database!"
        DB[:match].where(code: match['key']).update(name: match['name'])
        next
    end
    begin
        p match['name']
        DB[:events].insert(name: match['name'], code: match['key'])
    rescue => e
        puts "Problem with #{match}!"
        binding.irb
    end
end