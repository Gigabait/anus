local plugin = {}
plugin.id = "adduser"
plugin.chatcommand = "!adduser"
plugin.name = "Add User"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player", 1 },
	{ Group = "string" }
}
plugin.description = "Adds a user to a group"
plugin.category = "User Management"
plugin.noCmdMenu = true
plugin.defaultAccess = "superadmin"
plugin.noTempAccess = true

function plugin:OnRun( caller, target, group )
	target = target[ 1 ]
	if not anus.Groups[ group ] then
		caller:ChatPrint( "You have to give the right group!" )
		return
	end
	if IsValid( caller ) and caller:GetUserGroup() != "owner" then
		if anus.groupHasInheritanceFrom( group, caller:GetUserGroup() ) or anus.groupHasInheritanceFrom( target:GetUserGroup(), caller:GetUserGroup() ) then
			caller:ChatPrint( "Unable to add user to group: Group is ranked higher than yours!" )
			return
		end
	end
	
	--if caller:isGreaterOrEqualTo( target ) then
		target:SetUserGroup( group, true, nil, caller:SteamID() )
		if anus.tempUsers[ target:SteamID() ] then anus.tempUsers[ target:SteamID() ] = nil end
	--end

	anus.notifyPlugin( caller, plugin.id, "added ", target, " to group ", anus.Colors.String, group )
end

function plugin:GetCustomSuggestions( args ) 
	local output = {}
	if args[ 1 ] and args[ 2 ] then
		for k,v in next, anus.Groups do
			if anus.groupHasInheritanceFrom( k, LocalPlayer():GetUserGroup() ) then continue end

			output[ #output + 1 ] = args[ 1 ] .. " " ..  k
		end
	end
	
		-- outputs additional outputs
		-- second argument overrides default behavior
	return output, false
end

anus.registerPlugin( plugin )

local plugin = {}
plugin.id = "adduserid"
plugin.name = "Add User ID"
plugin.author = "Shinycow"
plugin.arguments = {
	{ SteamID = "string" },
	{ Group = "string" }
}
plugin.description = "Adds a steamid to a group"
plugin.category = "User Management"
plugin.noCmdMenu = true
plugin.defaultAccess = "owner"
plugin.noTempAccess = true

function plugin:OnRun( caller, steamid, group )
	if not anus.Groups[ group ] then
		caller:ChatPrint( "You have to give the right group!" )
		return
	end
	
	if IsValid( caller ) then
		if anus.groupHasInheritanceFrom( group, caller:GetUserGroup() ) then
			caller:ChatPrint( "That group is ranked higher than yours!" )
			return
		end
	end
	
	if not string.IsSteamID( steamid ) then
		caller:ChatPrint( "This isn't a valid steamid." )
		return
	end
		
	for k,v in ipairs( player.GetAll() ) do
		if v:SteamID() == steamid then
			caller:ChatPrint( "This command is reserved for offline users only!" )
			return
		end
	end
	
	if anus.Users[ steamid ] and not string.IsSteamID( anus.Users[ steamid ].name ) then
		anus.setPlayerGroup( steamid, group, nil, caller:SteamID() )
		anus.notifyPlugin( caller, plugin.id, "added steamid ", anus.Colors.SteamID, steamid, " (", anus.Colors.String, anus.Users[ steamid ].name, ") to group ", anus.Colors.String, group )
	else
		anus.setPlayerGroup( steamid, group, nil, caller:SteamID() )
		anus.notifyPlugin( caller, plugin.id, "added steamid ", anus.Colors.SteamID, steamid, " to group ", anus.Colors.String, group )
	end
end

anus.registerPlugin( plugin )

local plugin = {}
plugin.id = "addusertemp"
plugin.name = "Add Temp User"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player", 1 },
	{ Group = "string" },
	{ Time = "time" }
}
plugin.description = "Temporarily adds a user to a group"
plugin.category = "User Management"
plugin.noCmdMenu = true
plugin.defaultAccess = "superadmin"
plugin.noTempAccess = true

function plugin:OnRun( caller, target, group, time )
	target = target[ 1 ]
	if not anus.isValidGroup( group ) or group == "user" then
		caller:ChatPrint( "Invalid group supplied" ) 
		return
	end

	time = math.Clamp( time, 1, ANUS_YEAR )
	
	if caller:isGreaterThan( target ) then
		target:SetUserGroup( group, true, time, caller:SteamID() )
	end
	
	anus.notifyPlugin( caller, plugin.id, "added ", target, " to group ", anus.Colors.String, group, " for ", anus.Colors.String, anus.convertTimeToString( time ), "." )
end

anus.registerPlugin( plugin )


local plugin = {}
plugin.id = "removeuser"
plugin.name = "Remove User"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player", 1 }
}
plugin.description = "Removes all rights from a given user"
plugin.category = "User Management"
plugin.defaultAccess = "owner"
plugin.noTempAccess = true

function plugin:OnRun( caller, target )
	target = target[ 1 ]
	
	anus.Users[ target:SteamID() ] = nil
	target:SetUserGroup( "user", false, nil, caller:SteamID() )
end

anus.registerPlugin( plugin )


local plugin = {}
plugin.id = "adduseridtemp"
plugin.name = "Add Temp ID User"
plugin.author = "Shinycow"
plugin.arguments = {
	{ SteamID = "string" },
	{ Group = "string" },
	{ Time = "time" }
}
plugin.description = "Temporarily adds a user to a group"
plugin.category = "User Management"
plugin.defaultAccess = "superadmin"
plugin.noTempAccess = true

function plugin:OnRun( caller, steamid, group, time )
	if not anus.isValidGroup( group ) or group == "user" then
		anus.playerNotification( caller, "You can't add a user to this group!" )
		return
	end
	
	local time = math.Clamp( time, 1, ANUS_YEAR )
	
	if IsValid( caller ) then
		if anus.groupHasInheritanceFrom( group, caller.anusUserGroup ) then
			caller:ChatPrint( "Unable to add user to group: Group is ranked higher than yours!" )
			return
		end
	end
		
	anus.setPlayerGroup( steamid, group, time, caller:SteamID() )
	
	anus.notifyPlugin( caller, plugin.id, "added ", anus.Colors.SteamID, steamid, " to group ", anus.Colors.String, group, " for ", anus.Colors.String, anus.convertTimeToString( time ), "." )
end
anus.registerPlugin( plugin )




local aids = true
if aids then return end


local plugin = {}
plugin.id = "userallow"
plugin.name = "User Allow"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>; <string:Plugin>; [string:Restrictions]"
plugin.help = "Grants a player access to a command"
plugin.category = "User Management"
plugin.defaultAccess = "owner"

function plugin:OnRun( pl, arg, target )
	if #target > 1 then
		pl:ChatPrint( "You can only target one person at a time" )
		return 
	end
	if pl:isAnusTempRank() then
		pl:ChatPrint( "Denied: You're a temporary admin!" )
		return 
	end
	
	target = target[ 1 ]
	
	target:grantPermission( arg[ 1 ] )
	anus.notifyPlugin( pl, plugin.id, "granted permission ", COLOR_STRINGARGS, arg[ 1 ], " to ", target, "." )
end
anus.registerPlugin( plugin )

local plugin = {}
plugin.id = "userallowid"
plugin.name = "User Allow ID"
plugin.author = "Shinycow"
plugin.usage = "<string:SteamID>; <string:Plugin>; [string:Restrictions]"
plugin.help = "Grants a steamid access to a command"
plugin.category = "User Management"
plugin.defaultAccess = "owner"

function plugin:OnRun( pl, arg, target )
	if not string.IsSteamID( arg[ 1 ] ) then
		pl:ChatPrint( "No valid steamid supplied" )
		return 
	end
	if pl:isAnusTempRank() then
		pl:ChatPrint( "Denied: You're a temporary admin!" )
		return 
	end
	
	anus.grantPermission( arg[ 1 ], arg[ 2 ] )
	anus.notifyPlugin( pl, plugin.id, "granted permission ", COLOR_STRINGARGS, arg[ 2 ], " to steamid ", COLOR_STEAMIDARGS, arg[ 1 ], "." )
end
anus.registerPlugin( plugin )

local plugin = {}
plugin.id = "userrevoke"
plugin.name = "User Revoke"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>; <string:Plugin>"
plugin.help = "Revokes player access to a command"
plugin.category = "User Management"
plugin.defaultAccess = "owner"

function plugin:OnRun( pl, arg, target )
	if #target > 1 then
		pl:ChatPrint( "You can only target one person at a time" )
		return 
	end
	if pl:isAnusTempRank() then
		pl:ChatPrint( "Denied: You're a temporary admin!" )
		return 
	end
	
	target = target[ 1 ]

	target:revokePermission( arg[ 1 ] )
	anus.notifyPlugin( pl, plugin.id, "revoked permission ", COLOR_STRINGARGS, arg[ 1 ], " to ", target, "." )
end
anus.registerPlugin( plugin )

local plugin = {}
plugin.id = "userrevokeid"
plugin.name = "User Revoke ID"
plugin.author = "Shinycow"
plugin.usage = "<string:SteamID>; <string:Plugin>"
plugin.help = "Revokes a player access to a command"
plugin.category = "User Management"
plugin.defaultAccess = "owner"

function plugin:OnRun( pl, arg, target )
	if not string.IsSteamID( arg[ 1 ] ) then
		pl:ChatPrint( "No valid steamid supplied" )
		return 
	end
	if pl:isAnusTempRank() then
		pl:ChatPrint( "You already have temp admin!" )
		return 
	end
	
	anus.revokePermission( arg[ 1 ], arg[ 2 ] )
	anus.notifyPlugin( pl, plugin.id, "revoked permission ", COLOR_STRINGARGS, arg[ 2 ], " to steamid ", COLOR_STEAMIDARGS, arg[ 1 ], "." )
end
anus.registerPlugin( plugin )

local plugin = {}
plugin.id = "userdeny"
plugin.name = "User Deny"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>; <string:Plugin>"
plugin.help = "Disallows a player access to a command"
plugin.category = "User Management"
plugin.defaultAccess = "owner"

function plugin:OnRun( pl, arg, target )
	if #target > 1 then
		pl:ChatPrint( "You can only target one person at a time" )
		return 
	end
	if pl:isAnusTempRank() then
		pl:ChatPrint( "Denied: You're a temporary admin!" )
		return 
	end
	
	target = target[ 1 ]
	
	target:denyPermission( arg[ 1 ] )
	anus.notifyPlugin( pl, plugin.id, "denied permission ", COLOR_STRINGARGS, arg[ 1 ], " to ", target, "." )
end
anus.registerPlugin( plugin )

local plugin = {}
plugin.id = "userdenyid"
plugin.name = "User Deny ID"
plugin.author = "Shinycow"
plugin.usage = "<string:SteamID>; <string:Plugin>"
plugin.help = "Disallows a steamid access to a command"
plugin.category = "User Management"
plugin.defaultAccess = "owner"

function plugin:OnRun( pl, arg, target )
	if not string.IsSteamID( arg[ 1 ] ) then
		pl:ChatPrint( "No valid steamid supplied" )
		return 
	end
	if pl:isAnusTempRank() then
		pl:ChatPrint( "Denied: You're a temporary admin!" )
		return 
	end
	
	anus.denyPermission( arg[ 1 ], arg[ 2 ] )
	anus.notifyPlugin( pl, plugin.id, "denied permission ", COLOR_STRINGARGS, arg[ 2 ], " to steamid ", COLOR_STEAMIDARGS, arg[ 1 ], "." )
end
anus.registerPlugin( plugin )