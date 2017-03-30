local plugin = {}
plugin.id = "ban"
plugin.chatcommand = { "!ban" }
plugin.name = "Ban"
plugin.author = "Shinycow"
plugin.arguments = {
		-- Max players allowed in this case: 1
	{ Target = "player", 1 },
	{ Time = "time", 0 }, 
	{ Reason = "string", "No reason given" }
}
plugin.optionalarguments =
{
	"Time",
	"Reason"
}
plugin.description = "Bans a player from the server"
plugin.example = "!ban bot01 1d 1 day ban." 
plugin.category = "Utility"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target, time, reason )
	if #target > 1 then
		caller:ChatPrint( "You can only ban one player at a time." )
		return
	end
	
	target = target[ 1 ]

	--[[if not caller:isGreaterOrEqualTo( target ) then
		caller:ChatPrint( "Sorry, you can't target " .. target:Nick() )
		return
	end]]

	anus.notifyPlugin( caller, plugin.id, "banned ", target, " for ", anus.Colors.String, anus.convertTimeToString( time ), " (", anus.Colors.String, reason, ")" )
	target:PrintMessage( HUD_PRINTCONSOLE, string.rep( "-", 36 ) )
	target:PrintMessage( HUD_PRINTCONSOLE, "Banned from server by " .. caller:SteamID() .. " for " .. anus.convertTimeToString( time ) )
	target:PrintMessage( HUD_PRINTCONSOLE, "Ban Reason: " .. reason )
	target:PrintMessage( HUD_PRINTCONSOLE, string.rep( "-", 36 ) )
	timer.Simple( 0.1, function()
		if not IsValid( target ) then return end
		anus.banPlayer( caller, target, reason, time )
	end )
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
			local runtype = "\"" .. target:Nick() .. "\""
			
			pl:ConCommand( "anus " .. self.id .. " " .. runtype .. " " .. times[ i ][ 2 ] )
		end )
		
		for k=1,#reasons do
			menu2:AddOption( reasons[ k ], function()
				local runtype = "\"" .. target:Nick() .. "\""
				
				pl:ConCommand( "anus " .. self.id .. " " .. runtype .. " " .. time .. " " .. reasons[ k ] )
			end )
		end
		
		menu2:AddOption( "Custom reason", function()
			Derma_StringRequest( 
				target:Nick(), 
				"Custom ban reason",
				"No reason given",
				function( txt )
					local runtype = "\"" .. target:Nick() .. "\""

					pl:ConCommand( "anus " .. self.id .. " " .. runtype .. " " .. time .. " " .. txt )
				end,
				function( txt ) 
				end
			)
		end )
	end
	
end
anus.registerPlugin( plugin )


local plugin = {}
plugin.id = "banid"
plugin.name = "BanID"
plugin.author = "Shinycow"
plugin.arguments = {
	{ SteamID = "string" },
	{ Time = "time", 0 },
	{ Reason = "string", "No reason given." }
}
plugin.optionalarguments = 
{
	"Time",
	"Reason"
}
plugin.description = "Bans a player using their steamid"
plugin.example = "anus banid STEAM_0:1:99213 30m trolling"
plugin.notarget = true
plugin.category = "Utility"
plugin.defaultAcess = "superadmin"

function plugin:OnRun( caller, steamid, time, reason )
	if not string.IsSteamID( steamid ) then
		caller:ChatPrint( "This isn't a valid steamid." )
		return
	end
	
	if anus.Users[ steamid ] and anus.groupHasInheritanceFrom( anus.Users[ steamid ].group, caller.anusUserGroup ) then
		anus.playerNotification( caller, "The admin ", anus.Colors.SteamID, steamid, " has greater permissions than you." )
		return
	end

	anus.notifyPlugin( caller, plugin.id, "banned steamid ", anus.Colors.SteamID, steamid, " for ", anus.Colors.String, anus.convertTimeToString( time ), " (", anus.Colors.String, reason, ")" )
	anus.banPlayer( caller, steamid, reason, time )
end

anus.registerPlugin( plugin )


if SERVER then
	anus.registerAccessTag( "unbanAll", "superadmin", "Allows for unbanning anyone; not limited to unbanning players self-banned." )
end

local plugin = {}
plugin.id = "unban"
plugin.chatcommand = { "!unban" }
plugin.name = "Unban"
plugin.author = "Shinycow"
plugin.arguments = {
	{ SteamID = "string" },
	{ Reason = "string", "Unbanned" }
}
plugin.optionalarguments =
{
	"Reason"
}
plugin.description = "Unbans a player from the server"
plugin.example = "anus unban STEAM_0:0:12345678" 
plugin.notarget = true
plugin.category = "Utility"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, steamid, reason )
	if not string.IsSteamID( steamid ) then
		anus.playerNotification( caller, "This isn't a valid steamid." )
		return
	end
	if not anus.Bans[ steamid ] then
		anus.playerNotification( caller, "This steamid isn't banned!" )
		return
	end
	
	if not caller:hasAccess( "unbanAll" ) and anus.Bans[ steamid ].admin_steamid != caller:SteamID() then
		anus.playerNotification( caller, "You don't have permission to unban this player!" )
		return
	end

	local Unban = 
	{
	"unbanned ",
	anus.Colors.SteamID,
	steamid,
	" (",
	reason,
	")"
	}
	
	if anus.Bans[ steamid ] then
		table.insert( Unban, 4, " (" )
		table.insert( Unban, 5, anus.Colors.String )
		table.insert( Unban, 6, anus.Bans[ steamid ].name )
		table.insert( Unban, 7, " )" )
	end
	
	anus.notifyPlugin( caller, plugin.id, unpack( Unban ) )
	anus.unbanPlayer( caller, steamid )
end
anus.registerPlugin( plugin )

local plugin = {}
plugin.id = "banhistory"
plugin.chatcommand = { "!banhistory" }
plugin.name = "Ban History"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player", 1 }
}
plugin.description = "Checks ban history for a player"
plugin.example = "anus banhistory bot" 
plugin.category = "Utility"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( caller, target )
	target = target[ 1 ]

	anus.notifyPlugin( caller, plugin.id, "checked the ban history of ", target )
	
	if not target:hasBanHistory() then
		caller:ChatPrint( "No prior ban history found for " .. target:Nick() )
		return
	end
	
	local data = target:getBanHistory()
	
	caller:ChatPrint( "Check console for ban history of " .. target:Nick() )

	caller:PrintMessage( HUD_PRINTCONSOLE, "------------------------" )
	caller:PrintMessage( HUD_PRINTCONSOLE, target:Nick() .. " (" .. target:SteamID() .. ") ban history:" )

	local last = false
	for k,v in next, data do
		if not v.unbandate then continue end
		if k == #data then
			last = true
		end
		
		--pl:PrintMessage( HUD_PRINTCONSOLE, "\tPrevious name: ".. v.name .. "\n\tDate of ban: " .. os.date( v.dateofban ) .. "\n\tBan Length: " .. anus.convertTimeToString( v.time ) )
		caller:PrintMessage( HUD_PRINTCONSOLE, [[
	Previous name: ]] .. v.name .. [[ 
	Date of ban: ]] .. os.date( "%X - %d/%m/%Y", v.dateofban ) .. [[ 
	Ban Length: ]] .. anus.convertTimeToString( v.unbandate - v.dateofban ) .. [[ 
	Ban Reason: ]] .. v.reason .. [[ 
	Admin SteamID: ]] .. v.admin_steamid .. (last == false and "\n\n" or "")
		)
	end
	caller:PrintMessage( HUD_PRINTCONSOLE, "------------------------" )
end

function plugin:SelectFromMenu( pl, parent, target, line )
	parent:AddOption( self.name, function()
		local runtype = "\"" .. target:Nick() .. "\""

		pl:ConCommand( "anus " .. self.id .. " " .. runtype )
	end )
end
anus.registerPlugin( plugin )


local plugin = {}
plugin.id = "banhistoryid"
plugin.chatcommand = { "!banhistoryid" }
plugin.name = "Ban History ID"
plugin.author = "Shinycow"
plugin.arguments = {
	{ SteamID = "string" }
}
plugin.description = "Checks ban history for a steamid"
plugin.example = "anus banhistoryid STEAM_0:0:12345" 
plugin.category = "Utility"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( caller, steamid )
	if not string.IsSteamID( steamid ) then
		caller:ChatPrint( "This isn't a valid steamid." )
		return
	end
	anus.notifyPlugin( caller, plugin.id, "checked the ban history of ", anus.Colors.String, steamid )
	
	if not anus.playerHasBanHistory( steamid ) then
		caller:ChatPrint( "No prior ban history found for " .. steamid )
		return
	end
	
	local data = anus.playerGetBanHistory( steamid )
	
	caller:ChatPrint( "Check console for ban history of " .. steamid )

	caller:PrintMessage( HUD_PRINTCONSOLE, "------------------------" )
	caller:PrintMessage( HUD_PRINTCONSOLE, steamid .. " ban history:" )

	local last = false
	for k,v in next, data do
		if not v.unbandate then continue end
		if k == #data then
			last = true
		end
		
		--pl:PrintMessage( HUD_PRINTCONSOLE, "\tPrevious name: ".. v.name .. "\n\tDate of ban: " .. os.date( v.dateofban ) .. "\n\tBan Length: " .. anus.convertTimeToString( v.time ) )
		caller:PrintMessage( HUD_PRINTCONSOLE, [[
	Previous name: ]] .. v.name .. [[ 
	Date of ban: ]] .. os.date( "%X - %d/%m/%Y", v.dateofban ) .. [[ 
	Ban Length: ]] .. anus.convertTimeToString( v.unbandate != 0 and v.unbandate - v.dateofban or v.unbandate ) .. [[ 
	Ban Reason: ]] .. v.reason .. [[ 
	Admin SteamID: ]] .. v.admin_steamid .. (last == false and "\n\n" or "")
		)
	end
	caller:PrintMessage( HUD_PRINTCONSOLE, "------------------------" )
end
anus.registerPlugin( plugin )
