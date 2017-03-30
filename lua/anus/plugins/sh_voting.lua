local plugin = {}
plugin.id = "vote"
plugin.chatcommand = { "!vote" }
plugin.name = "Vote"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Title = "string" },
	{ Time = "number" },
	{ Options = "string" }
}
	-- Args are seperated so a command ran like ( anus vote "Cool name" "yes" "no" "i dont care" )
	-- Without:
	-- Options: "yes no i dont care"
	-- With:
	-- Options
	--		1: yes
	--		2: no
	--		3: i dont care
plugin.argumentsFormatted = 
{
	[ "Options" ] = true
}
plugin.description = "Starts a vote"
plugin.category = "Voting"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, title, time, options )
	local vote, err = anus.startVote( title, options, time, function( res )
		caller:ChatPrint( "Vote \"" .. title .. "\" has ended" )

		local winner = nil
		local votecount = 0
		for k,v in next, res.answers do
			if v > votecount then
				winner = k
				votecount = v
			end
		end

		if winner then
			for k,v in ipairs( player.GetAll() ) do
				v:ChatPrint( "Vote winner is " .. res.args[ winner ] .. ". (" .. votecount .. "/" .. res.voters .. ")" )
			end
		else
			for k,v in ipairs( player.GetAll() ) do
				v:ChatPrint( "Vote was ended with no winner." )
			end
		end

	end, caller )

	if not vote then anus.notifyPlayer( caller, err ) return end
	anus.notifyPlugin( caller, plugin.id, "started vote ", anus.Colors.String, "\"" .. title .. "\"" )
end

anus.registerPlugin( plugin )


local plugin = {}
plugin.id = "votemap"
plugin.chatcommand = { "!votemap" }
plugin.name = "Votemap"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Time = "number" },
	{ Options = "string" }
}
plugin.description = "Starts a vote"
plugin.category = "Voting"
plugin.noCmdMenu = true
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, time, options )
	local title = "Vote Map"
	local args = {}

	options = string.Explode( " ", options )
	for k,v in ipairs( options or {} ) do
		if #args > 9 then break end
		if not anus_votemaps[ v:lower() ] then
			caller:ChatPrint( "Map \"" .. v .. "\" was not found." )
			return
		end

		args[ #args + 1 ] = v
	end

	if #args == 1 then
		caller:ChatPrint( "Votemap requires at least two options!" )
		return
	end

	local vote, err = anus.startVote( title, args, time, function( res )
		caller:ChatPrint( "Votemap \"" .. title .. "\" has ended" )

		local winner = nil
		local votecount = 0
		for k,v in next, res.answers do
			if v > votecount then
				winner = k
				votecount = v
			end
		end

		if winner then
			for k,v in ipairs( player.GetAll() ) do
				v:ChatPrint( "Votemap winner is " .. res.args[ winner ] .. ". (" .. votecount .. "/" .. res.voters .. ")" )
				v:ChatPrint( "Changing map to " .. res.args[ winner ] .. " in 5 seconds." )
			end
			timer.Create( "anus_VotemapSuccessful", hook.Call( "anus_VotemapChangeTime", nil ), 1, function()
				if anus.getPlugins()[ "map" ] and not anus.getPlugins()[ "map" ].disabled then
					anus.runCommand( "map", NULL, res.args[ winner ] )
				else
					game.ConsoleCommand( "anus map " .. res.args[ winner ] .. "\n" )
				end
			end )
		else
			for k,v in ipairs( player.GetAll() ) do
				v:ChatPrint( "Votemap was ended with no winner." )
			end
		end

	end, caller )

	if not vote then anus.playerNotification( caller, err ) return end
	anus.notifyPlugin( caller, plugin.id, "started votemap ", anus.Colors.String, "\"" .. title .. "\"" )
end

anus.registerPlugin( plugin )
anus.registerHook( "InitPostEntity", "votemap", function()
	anus_votemaps = anus_votemaps or {}

	local maps = file.Find( "maps/*.bsp", "GAME" )
	for k,v in next, maps do
		anus_votemaps[ string.StripExtension( v ):lower() ] = k
	end
end, plugin.id )

anus.registerHook( "anus_VotemapChangeTime", "votemap", function()
	return 5
end, plugin.id )

	-- votemap2: votes a single map, yes or no
local plugin = {}
plugin.id = "votemap2"
plugin.chatcommand = { "!votemap2" }
plugin.name = "Votemap2"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Time = "number" },
	{ Map = "string" }
}
plugin.description = "Starts a yes/no vote on a map"
plugin.category = "Voting"
plugin.noCmdMenu = true
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, time, map )
	if not anus_votemaps[ map:lower() ] then
		caller:ChatPrint( "Map \"" .. map .. "\" was not found." )
		return
	end

	local title = map
	local options = { "Yes", "No" }

	local vote, err = anus.startVote( title, options, time, function( res )
		caller:ChatPrint( "Votemap2 \"" .. title .. "\" has ended" )

		local Percentage = 3/5
		local Winner = nil

		if res.answers[ 1 ] and res.answers[ 1 ] / res.voters >= Percentage then
			Winner = 1
		else
			Winner = 2
		end

		if Winner and Winner == 1 then
			for k,v in ipairs( player.GetAll() ) do
				v:ChatPrint( "Votemap2 winner is " .. res.args[ Winner ] .. ". (" .. res.answers[ 1 ] .. "/" .. res.voters .. ")" )
				v:ChatPrint( "Changing map to " .. title .. " in 15 seconds." )
			end
			timer.Create( "anus_VotemapSuccessful", hook.Call( "anus_Votemap2ChangeTime", nil ), 1, function()
				if anus.getPlugins()[ "map" ] and not anus.getPlugins()[ "map" ].disabled then
					anus.runCommand( "map", NULL, title )
				else
					game.ConsoleCommand( "anus map " .. title .. "\n" )
				end
			end )
		else
			for k,v in ipairs( player.GetAll() ) do
				v:ChatPrint( "Votemap2 failed. Map will not be changed. (" .. (res.answers[ 1 ] or 0) .. "/" .. res.voters .. ")" )
			end
		end

	end, caller )

	if not vote then anus.playerNotification( caller, err ) return end
	anus.notifyPlugin( caller, plugin.id, "started votemap2 ", anus.Colors.String, "\"" .. title .. "\"" )
end

anus.registerPlugin( plugin )
anus.registerHook( "InitPostEntity", "votemap2", function()
	anus_votemaps = anus_votemaps or {}

	local maps = file.Find( "maps/*.bsp", "GAME" )
	for k,v in next, maps do
		anus_votemaps[ string.StripExtension( v ):lower() ] = k
	end
end, plugin.id )
anus.registerHook( "anus_Votemap2ChangeTime", "votemap2", function()
	return 15
end, plugin.id )

local plugin = {}
plugin.id = "cancelvote"
plugin.chatcommand = { "!cancelvote" }
plugin.name = "Cancel Vote"
plugin.author = "Shinycow"
plugin.description = "Cancels the current vote"
plugin.category = "Voting"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( caller ) 
	if not anus.VoteExists() then
		caller:ChatPrint( "There is no vote in progress!" )
		return
	end

	local title = anus.CancelVote()
	anus.notifyPlugin( caller, plugin.id, "canceled vote ", anus.Colors.String, "\"" .. title .. "\"" )
end

anus.registerPlugin( plugin )


---- votekick / voteban

-- 
if SERVER then
	anus.registerCVar( "votekick_succeed_ratio", "60", "Percentage of votes required for a player to be kicked", "superadmin" )
end

local plugin = {}
plugin.id = "votekick"
plugin.chatcommand = "!votekick"
plugin.name = "Vote kick"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" },
	{ Reason = "string" }
}
plugin.optionalarguments =
{
	"Reason"
}
plugin.description = "Votes to kick a player off the server"
plugin.category = "Voting"
plugin.defaultAccess = "trusted"

function plugin:OnRun( caller, target, reason )
	target = target[ 1 ]
	local Title = "Kick " .. target:Nick() .. "?"
	if #player.GetAll() < 3 then anus.playerNotification( caller, "More players are needed to start a votekick" ) return end

	local TargetNick = target:Nick()

	local Vote, Err = anus.startVote( Title, { "Yes", "No" }, 15, function( res )
		caller:ChatPrint( "Vote \"" .. Title .. "\" has ended" )

		local Total = res.voters
		local Percentage = GetConVarString( "anus_votekick_succeed_ratio" )
		Percentage = tonumber( Percentage ) != nil and tonumber( Percentage ) / 100 or 3/5
		local Winner = nil

		if res.answers[ 1 ] and res.answers[ 1 ] / Total >= Percentage then
			Winner = 1
		else
			Winner = 2
		end

		if Winner == 1 then
			for k,v in ipairs( player.GetAll() ) do
				v:ChatPrint( "Votekick against " .. TargetNick .. " succeeded. (" .. res.answers[ 1 ] .. "/" .. Total .. ")" )
			end
			
			if not IsValid( target ) then return end
			if anus.isPluginDisabled( "kick" ) then
				game.ConsoleCommand( "kickid " .. target:UserID() .. " Votekicked by " .. caller:SteamID() .. "\n" )
			else
				anus.runCommand( "kick", NULL, { target }, "Votekicked." )
			end
		else
			for k,v in ipairs( player.GetAll() ) do
				v:ChatPrint( "Votekick against " .. TargetNick .. " has failed. (" .. (res.answers[ 1 ] or 0) .. "/" .. Total .. ")" )
			end
		end
	end, caller )

	if not Vote then anus.notifyPlayer( caller, Err ) return end
	anus.notifyPlugin( caller, plugin.id, "started vote ", anus.Colors.String, "\"" .. Title .. "\"" )
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	parent:AddOption( self.name, function()
		local runtype = "\"" .. target:Nick() .. "\""

		pl:ConCommand( "anus " .. self.id .. " " .. runtype )
	end )
end

anus.registerPlugin( plugin )

if SERVER then
	anus.registerCVar( "voteban_succeed_ratio", "75", "Percentage of votes required for a player to be banned", "superadmin" )
	anus.registerCVar( "voteban_bantime", "15", "Ban time in minutes", "superadmin" )
end

local plugin = {}
plugin.id = "voteban"
plugin.chatcommand = "!voteban"
plugin.name = "Vote ban"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" },
	{ Reason = "string" }
}
plugin.optionalarguments =
{
	"Reason"
}
plugin.description = "Votes to ban a player from the server"
plugin.category = "Voting"
plugin.defaultAccess = "trusted"

function plugin:OnRun( caller, target, reason )
	target = target[ 1 ]
	local Title = "Ban " .. target:Nick() .. "?"
	if #player.GetAll() < 4 then anus.playerNotification( caller, "More players are needed to start a voteban" ) return end

	local TargetNick = target:Nick()
	local TargetSteam = target:SteamID()
	local BanTime = GetConVarString( "anus_voteban_bantime" )
	BanTime = tonumber( BanTime ) != nil and tonumber( BanTime ) or 15

	local Vote, Err = anus.startVote( Title, { "Yes", "No" }, 15, function( res )
		caller:ChatPrint( "Vote \"" .. Title .. "\" has ended" )

		local Total = res.voters
		local Percentage = GetConVarString( "anus_voteban_succeed_ratio" )
		Percentage = tonumber( Percentage ) != nil and tonumber( Percentage ) / 100 or 6/8
		local Winner = nil

		if res.answers[ 1 ] and res.answers[ 1 ] / Total >= Percentage then
			Winner = 1
		else
			Winner = 2
		end

		if Winner == 1 then
			for k,v in ipairs( player.GetAll() ) do
				v:ChatPrint( "Voteban against " .. TargetNick .. " succeeded. (" .. res.answers[ 1 ] .. "/" .. Total .. ")" )
			end
			
			if anus.isPluginDisabled( "banid" ) or anus.isPluginDisabled( "ban" ) or not IsValid( target ) then
				game.ConsoleCommand( "banid " .. BanTime .. " " .. TargetSteam .. " kick\n" )
			else
				anus.runCommand( "ban", NULL, { target }, BanTime * 60, "Votebanned by " .. caller:SteamID() .. " for " .. BanTime * 60 .. " minutes. " )
			end
		else
			for k,v in ipairs( player.GetAll() ) do
				v:ChatPrint( "Voteban against " .. TargetNick .. " has failed. (" .. (res.answers[ 1 ] or 0) .. "/" .. Total .. ")" )
			end
		end
	end, caller )

	if not Vote then anus.notifyPlayer( caller, Err ) return end
	anus.notifyPlugin( caller, plugin.id, "started vote ", anus.Colors.String, "\"" .. Title .. "\"" )
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	parent:AddOption( self.name, function()
		local runtype = "\"" .. target:Nick() .. "\""

		pl:ConCommand( "anus " .. self.id .. " " .. runtype )
	end )
end

anus.registerPlugin( plugin )