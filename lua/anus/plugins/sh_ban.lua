local plugin = {}
plugin.id = "ban"
plugin.name = "Ban"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>; [number:Time]; [string:Reason]"
	-- String;Default reason
plugin.args = {"Int;0;1461", "String;No reason given."}
plugin.help = "Bans a player from the server"
plugin.example = "!ban bot01 1d 1 day ban." 
plugin.category = "Utility"
plugin.chatcommand = "ban"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, arg, target )
	if #target > 1 then
		pl:ChatPrint( "You can only ban one player at a time." )
		return
	end
	
	target = target[ 1 ]

	local reason = "No reason given."
	local newarg = {}
	local time = 0
	
	if #arg > 0 then
		time = arg[ 1 ]
		
		if #arg > 1 then
			for i=2,#arg do
				local v = arg[i]
				newarg[ #newarg + 1 ] = v
			end
			
			reason = table.concat( newarg, " " )
		end
	end

	if not pl:IsGreaterOrEqualTo( target ) then
		pl:ChatPrint("Sorry, you can't target " .. target:Nick())
		return
	end

	anus.NotifyPlugin( pl, plugin.id, "banned ", target, " for ", COLOR_STRINGARGS, anus.ConvertTimeToString( time ), " (", COLOR_STRINGARGS, reason, ")" )
	target:PrintMessage( HUD_PRINTCONSOLE, "------------------------" )
	target:PrintMessage( HUD_PRINTCONSOLE, "Banned from server by " .. pl:SteamID() .. " for " .. reason .. " for " .. anus.ConvertTimeToString( time ) )
	target:PrintMessage( HUD_PRINTCONSOLE, "------------------------" )
	timer.Simple(0.1, function()
		if not IsValid(target) then return end
		anus.BanPlayer( pl, target, reason, time )
	end)
end

function plugin:GetUsageSuggestions( arg, pl )
	local playerinfo = pl.PlayerInfo[ pl ][ "perms" ]
	if not playerinfo[ "ban" ] or type( playerinfo[ "ban" ] ) != "table" then return "" end
	if arg == 2 and playerinfo[ "ban" ][ 2 ] then

		playerinfo = playerinfo[ "ban" ][ 2 ]
		
		local str = ""
		str = playerinfo[ "min" ] and "min " .. playerinfo[ "min" ] .. " "
		str = playerinfo[ "max" ] and str .. "max " .. playerinfo[ "max" ] or str
		
		return str
	
	else
		
		return ""
	
	end
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	local menu, label = parent:AddSubMenu( self.name )
	
	local times =
	{
	{ "1 minute", "1m" },
	{ "15 minutes", "15m" },
	{ "30 minutes", "30m" },
	{ "1 hour", "1h" },
	{ "12 hours", "12h" },
	{ "1 day", "1d" },
	{ "1 week", "1w" },
	{ "1 month", "1M" },
	{ "Permanently", "0" },
	}
	
	local reasons =
	{
	"Advertising",
	"DDoS threat",
	"Disrespectful",
	"Mingebag",
	"Rule breaker",
	"Spamming",
	"No reason given",
	}
	
	for i=1,#times do
		local time = times[ i ][ 2 ]
		local menu2 = menu:AddSubMenu( times[ i ][ 1 ], function()
			local runtype = target:SteamID()
			if target:IsBot() then runtype = target:Nick() end
			
			pl:ConCommand( "anus " .. self.chatcommand .. " " .. runtype .. " " .. times[ i ][ 2 ] )
		end )
		
		for k=1,#reasons do
			menu2:AddOption( reasons[ k ], function()
				local runtype = target:SteamID()
				if target:IsBot() then runtype = target:Nick() end
				
				pl:ConCommand( "anus " .. self.chatcommand .. " " .. runtype .. " " .. time .. " " .. reasons[ k ] )
			end )
		end
		
		menu2:AddOption( "Custom reason", function()
			Derma_StringRequest( 
				target:Nick(), 
				"Custom ban reason",
				"No reason given",
				function( txt )
					local runtype = target:SteamID()
					if target:IsBot() then runtype = target:Nick() end

					pl:ConCommand( "anus " .. self.chatcommand .. " " .. runtype .. " " .. time .. " " .. txt )
				end,
				function( txt ) 
				end
			)
		end )
	end
	
end
anus.RegisterPlugin( plugin )

local plugin = {}
plugin.id = "banid"
plugin.name = "BanID"
plugin.author = "Shinycow"
plugin.usage = "<string:SteamID>; [number:Time]; [string:Reason]"
	-- String;Default reason
plugin.args = {"String;STEAM_0:", "Int;0;1461;", "String;No reason given."}
plugin.help = "Bans a player using their steamid"
plugin.example = "anus banid STEAM_0:1:99213 30m trolling"
plugin.notarget = true
plugin.category = "Utility"
plugin.defaultAcess = "superadmin"

function plugin:OnRun( pl, arg, target )
	local time = 0
	local reason = "No reason given."
	local newarg = {}
	
	if #arg > 1 then
		time = arg[ 2 ]
		
		if #arg > 2 then
			for i=3,#arg do
				local v = arg[i]
				newarg[ #newarg + 1 ] = v
			end
			reason = table.concat( newarg, " " )
		end
	end

	if anus.Users[ arg[ 1 ] ] and anus.GroupHasInheritanceFrom( anus.Users[ arg[ 1 ] ].group, pl.UserGroup ) then
		pl:ChatPrint("Sorry, this player is higher ranked than you!")
		return
	end
	
	if not string.match( arg[ 1 ], "STEAM_0:[0-1]:[0-9]+" ) then
		pl:ChatPrint("This isn't a valid steamid.")
		return
	end

	anus.NotifyPlugin( pl, plugin.id, true, COLOR_STEAMIDARGS, arg[1], " has been banned for ", COLOR_STRINGARGS, anus.ConvertTimeToString( time ), " (", COLOR_STRINGARGS, reason, ")" )
	anus.BanPlayer( pl, arg[ 1 ], reason, time )
end

function plugin:GetUsageSuggestions( arg, pl )
	local playerinfo = pl.PlayerInfo[ pl ][ "perms" ]
	if not playerinfo[ "banid" ] or type( playerinfo[ "banid" ] ) != "table" then return "" end
	if arg == 3 and playerinfo[ "banid" ][ 3 ] then

		playerinfo = playerinfo[ "banid" ][ 3 ]
		
		local str = ""
		str = playerinfo[ "min" ] and "min " .. playerinfo[ "min" ] .. " "
		str = playerinfo[ "max" ] and str .. "max " .. playerinfo[ "max" ] or str
		
		return str
	
	else
		
		return ""
	
	end
end

anus.RegisterPlugin( plugin )

local plugin = {}
plugin.id = "unban"
plugin.name = "Unban"
plugin.author = "Shinycow"
plugin.usage = "<string:SteamID>"
	-- String;Default reason
plugin.args = {"String;STEAM_0:"}
plugin.help = "Unbans a player from the server"
plugin.example = "anus unban STEAM_0:0:12345678" 
plugin.notarget = true
plugin.category = "Utility"
plugin.chatcommand = "unban"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, arg, target )
	if not string.match( arg[ 1 ], "STEAM_0:[0-1]:[0-9]+" ) then
		pl:ChatPrint("This isn't a valid steamid.")
		return
	end

	if #arg > 1 then
		for i=1,#arg do
			local v = arg[ i ]
			timer.Simple( 0.08 * i, function()
				anus.UnbanPlayer( pl, v )
			end )
		end
	else		
		anus.UnbanPlayer( pl, arg[ 1 ] )
	end
end
anus.RegisterPlugin( plugin )
