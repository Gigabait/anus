local plugin = {}
plugin.id = "vote"
plugin.name = "Vote"
plugin.author = "Shinycow"
plugin.usage = "<string:Title>; <number:Time>; <string:Options>"
plugin.help = "Starts a public vote"
plugin.category = "Voting"
	-- chat command optional
plugin.chatcommand = "vote"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, args )
	
	local title = args[ 1 ]
	local time = args[ 2 ]
	local options = {}
	
	for k,v in next, args or {} do
		if k == 1 or k == 2 then continue end
		if #options > 9 then break end
		
		options[ #options + 1 ] = v
	end
		
	anus.StartVote( title, options, tonumber(time), function( res ) 
		pl:ChatPrint( "Vote \"" .. title .. "\" has ended" )

		local winner = nil
		local votecount = 0
		for k,v in next, res.answers do
			if v > votecount then
				winner = k
				votecount = v
			end
		end
		
		if winner then
			ChatPrint( "Vote winner is " .. res.args[ winner ] .. ". (" .. votecount .. "/" .. res.voters .. ")" )
		else
			ChatPrint( "Vote was ended with no winner." )
		end
		
	end )

	anus.NotifyPlugin( pl, plugin.id, "started vote ", COLOR_STRINGARGS, "\"" .. title .. "\"" )
end

anus.RegisterPlugin( plugin )