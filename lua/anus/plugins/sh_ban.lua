local PLUGIN = {}
PLUGIN.id = "ban"
PLUGIN.name = "Ban"
PLUGIN.author = "Shinycow"
PLUGIN.usage = "<player:Player>; [string:Time]; [string:Reason]"
	-- String;Default reason
PLUGIN.args = {"Int;0;1461", "String;No reason given."}
PLUGIN.help = "Bans a player from the server"
PLUGIN.example = "!ban bot01 1440 1 day ban." 
PLUGIN.category = "Utility"
PLUGIN.chatcommand = "ban"
PLUGIN.defaultAccess = "admin"

function PLUGIN:OnRun( pl, arg, target )
	local reason = "No reason given."
	local newarg = {}
	local time = 0
	
	if #arg > 0 then
		--time = arg[1] and tonumber(arg[1]) or 60
		time = arg[ 1 ]
		if not tonumber( arg[ 1 ] ) then
			time = anus.ConvertStringToTime( arg[ 1 ] ) or anus.ConvertStringToTime( "1m" )
		end
		
		if #arg > 1 then
			for i=2,#arg do
				local v = arg[i]
				newarg[ #newarg + 1 ] = v
			end
			
			reason = table.concat( newarg, " " )
		end
	end
	
	if type(target) == "table" then pl:ChatPrint("Sorry, you can only target one player at a time.") return end
		
	if not pl:IsGreaterOrEqualTo( target ) then
		pl:ChatPrint("Sorry, you can't target " .. target:Nick())
		return
	end

	anus.NotifyPlugin( pl, PLUGIN.id, "banned ", target, " for ", COLOR_STRINGARGS, time .. " seconds ", "(", COLOR_STRINGARGS, reason, ")" )
	target:PrintMessage( HUD_PRINTCONSOLE, "------------------------" )
	target:PrintMessage( HUD_PRINTCONSOLE, "Banned from server by " .. pl:SteamID() .. " for " .. reason .. " for " .. time .. " seconds" )
	target:PrintMessage( HUD_PRINTCONSOLE, "------------------------" )
	timer.Simple(0.1, function()
		if not IsValid(target) then return end
		anus.BanPlayer( pl, target, reason, time )
	end)
end
anus.RegisterPlugin( PLUGIN )

local PLUGIN = {}
PLUGIN.id = "banid"
PLUGIN.name = "banid"
PLUGIN.author = "Shinycow"
PLUGIN.usage = "<string:SteamID>; [string:Time]; [string:Reason]"
	-- String;Default reason
PLUGIN.args = {"String;STEAM_0:", "Int;0;1461;", "String;No reason given."}
PLUGIN.help = "Bans a player using their steamid"
PLUGIN.example = "anus banid STEAM_0:1:99213 30 trolling"
PLUGIN.notarget = true
PLUGIN.category = "Utility"
PLUGIN.defaultAcess = "superadmin"

function PLUGIN:OnRun( pl, arg, target )
	local time = 0
	local reason = "No reason given."
	local newarg = {}
	
	if #arg > 1 then
		--time = arg[2] and tonumber(arg[2]) or 0
		time = arg[ 2 ]
		if not tonumber( arg[ 2 ] ) then
			time = anus.ConvertStringToTime( arg[ 2 ] ) or anus.ConvertStringToTime( "1m" )
		end
		
		if #arg > 2 then
			for i=3,#arg do
				local v = arg[i]
				newarg[ #newarg + 1 ] = v
			end
			reason = table.concat( newarg, " " )
		end
	end

	if anus.Users[ arg[ 1 ] ] and anus.GroupHasInheritanceFrom( anus.Groups[ anus.Users[ arg[ 1 ] ].group ], pl.UserGroup ) then
		pl:ChatPrint("Sorry, this player is higher ranked than you!")
		return
	end
	
	if not string.match( arg[1], "STEAM_0:[0-1]:[0-9]+" ) then
		pl:ChatPrint("This isn't a valid steamid.")
		return
	end

	anus.NotifyPlugin( pl, PLUGIN.id, true, COLOR_STEAMIDARGS, arg[1], " has been banned for ", COLOR_STRINGARGS, time .. " seconds ", "(", COLOR_STRINGARGS, reason, ")" )
	anus.BanPlayer( pl, arg[1], reason, time )
end
anus.RegisterPlugin( PLUGIN )

local PLUGIN = {}
PLUGIN.id = "unban"
PLUGIN.name = "Unban"
PLUGIN.author = "Shinycow"
PLUGIN.usage = "<string:SteamID>"
	-- String;Default reason
PLUGIN.args = {"String;STEAM_0:"}
PLUGIN.help = "Unbans a player from the server"
PLUGIN.example = "anus unban STEAM_0:0:12345678" 
PLUGIN.notarget = true
PLUGIN.category = "Utility"
PLUGIN.chatcommand = "unban"
PLUGIN.defaultAccess = "admin"

function PLUGIN:OnRun( pl, arg, target )
	if not string.match( arg[1], "STEAM_0:[0-1]:[0-9]+" ) then
		pl:ChatPrint("This isn't a valid steamid.")
		return
	end

	if #arg > 1 then
		for i=1,#arg do
			local v = arg[i]
			timer.Simple(0.08 * i, function()
				anus.UnbanPlayer( pl, v )
			end)
		end
	else		
		anus.UnbanPlayer( pl, arg[1] )
	end
end
anus.RegisterPlugin( PLUGIN )
