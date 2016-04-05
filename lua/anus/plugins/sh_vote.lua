local plugin = {}
plugin.id = "vote"
plugin.name = "Vote"
plugin.author = "Shinycow"
plugin.usage = "<string:Title>; <number:Time>; <string:Options>"
plugin.help = "Starts a vote"
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
		
	local vote = anus.StartVote( title, options, tonumber(time), function( res ) 
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

	if not vote then return end
	anus.NotifyPlugin( pl, plugin.id, "started vote ", COLOR_STRINGARGS, "\"" .. title .. "\"" )
end

anus.RegisterPlugin( plugin )

hook.Add( "InitPostEntity", "anus_plugins_votemap", function()
	anus_votemaps = {}
	
	local maps = file.Find( "maps/*.bsp", "GAME" )
	for k,v in next, maps do
		anus_votemaps[ string.StripExtension( v ) ] = k
	end
end )

local plugin = {}
plugin.id = "votemap"
plugin.name = "Votemap"
plugin.author = "Shinycow"
plugin.usage = "<number:Time>; <string:Options>"
plugin.help = "Starts a vote"
plugin.category = "Voting"
	-- chat command optional
plugin.chatcommand = "votemap"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, args )
	
	local title = "Vote Map"
	local time = args[ 1 ]
	local options = {}
	
	for k,v in next, args or {} do
		if k == 1 then continue end
		if #options > 9 then break end
		if not anus_votemaps[ v ] then
			pl:ChatPrint( "Map \"" .. v .. "\" was not found." )
			return
		end
		
		options[ #options + 1 ] = v
	end
		
	local vote = anus.StartVote( title, options, tonumber(time), function( res ) 
		pl:ChatPrint( "Votemap \"" .. title .. "\" has ended" )

		local winner = nil
		local votecount = 0
		for k,v in next, res.answers do
			if v > votecount then
				winner = k
				votecount = v
			end
		end
		
		if winner then
			ChatPrint( "Votemap winner is " .. res.args[ winner ] .. ". (" .. votecount .. "/" .. res.voters .. ")" )
			ChatPrint( "Changing map to " .. res.args[ winner ] .. " in 5 seconds." )
			timer.Create( "anus_VotemapSuccessful", 5, 1, function()
				if anus.GetPlugins()[ "map" ] then
					anus.RunCommand_map( NULL, nil, { res.args[ winner ] }, res.args[ winner ] )
				else
					game.ConsoleCommand( "anus map " .. res.args[ winner ] .. "\n" )
				end
			end )
		else
			ChatPrint( "Votemap was ended with no winner." )
		end
		
	end )

	if not vote then return end
	anus.NotifyPlugin( pl, plugin.id, "started votemap ", COLOR_STRINGARGS, "\"" .. title .. "\"" )
end

anus.RegisterPlugin( plugin )