local plugin = {}
plugin.id = "adduser"
plugin.name = "Add User"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>; <string:Group>"
	-- groups opens a dcombox of groups
plugin.args = {"Groups"}
plugin.help = "Adds a user to a group"
plugin.category = "Utility"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, args, target )
	if #target > 1 then 
		pl:ChatPrint( "You can only add one person to a group at a time!" )
		return
	end
	target = target[ 1 ]
	if not anus.Groups[ args[ 1 ] ] then
		pl:ChatPrint( "You have to give the right group!" )
		return
	end
	if pl:IsTempUser() then 
		pl:ChatPrint( "Access denied: You are a temporary admin" )
		return 
	end
	if IsValid( pl ) then
		if anus.GroupHasInheritanceFrom( args[ 1 ], pl.UserGroup ) then
			pl:ChatPrint( "Unable to add user to group: Group is ranked higher than yours!" )
			return
		end
	end
	
	if pl:IsGreaterOrEqualTo( target ) then
		target:SetUserGroup( args[ 1 ], true )
		if anus.TempUsers[ target:SteamID() ] then anus.TempUsers[ target:SteamID() ] = nil end
	end

	anus.NotifyPlugin( pl, plugin.id, "added ", target, " to group ", COLOR_STRINGARGS, args[ 1 ] )
end

function plugin:GetUsageSuggestions( arg )
	if arg != 2 then return "" end
	
	local output = {}
	for k,v in next, anus.Groups do
		output[ #output + 1 ] = k
	end

	table.SortDesc( output )
	
	local str = ""
	for i=1,#output do
		if #output == i then
			str = str .. output[ i ]
		else
			str = str .. output[ i ] .. ","
		end
	end
	
	return str
end

anus.RegisterPlugin( plugin )

local plugin = {}
plugin.id = "adduserid"
plugin.name = "Add User ID"
plugin.author = "Shinycow"
plugin.usage = "<string:SteamID>; <string:Group>"
	-- groups opens a dcombox of groups
plugin.args = {"String;STEAM_0:", "Groups"}
plugin.help = "Adds a steamid to a group"
plugin.notarget = true
plugin.category = "Utility"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, args, target )
	if not anus.Groups[ args[ 2 ] ] then
		pl:ChatPrint( "You have to give the right group!" )
		return
	end
	if pl:IsTempUser() then
		pl:ChatPrint( "Denied: You're a temporary admin!" ) 
		return
	end
	
	if IsValid( pl ) then
		if anus.GroupHasInheritanceFrom( args[ 2 ], pl.UserGroup ) then
			pl:ChatPrint( "Unable to add user to group: Group is ranked higher than yours!" )
			return
		end
	end
	
	local steamid = args[ 1 ]
	
	if not string.IsSteamID( steamid ) then
		pl:ChatPrint( "This isn't a valid steamid." )
		return
	end
		
	for k,v in next, player.GetAll() do
		if v:SteamID() == steamid then
			pl:ChatPrint( "You can't use this command on a player who is in the server! Use anus adduser instead!" )
		end
	end
		
	anus.SetPlayerGroup( steamid, args[2] )
	
	anus.NotifyPlugin( pl, plugin.id, "added steamid ", COLOR_STEAMIDARGS, steamid, " to group ", COLOR_STRINGARGS, args[ 2 ] )
end

function plugin:GetUsageSuggestions( arg )
	if arg != 2 then return "" end
	
	local output = {}
	for k,v in next, anus.Groups do
		output[ #output + 1 ] = k
	end

	table.SortDesc( output )
	
	local str = ""
	for i=1,#output do
		if #output == i then
			str = str .. output[ i ]
		else
			str = str .. output[ i ] .. ","
		end
	end
	
	return str
end

anus.RegisterPlugin( plugin )


local plugin = {}
plugin.id = "addusertemp"
plugin.name = "Add Temp User"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>; <string:Group>; <string:Time>"
plugin.help = "Temporarily adds a user to a group"
plugin.category = "Utility"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, arg, target )
	if #target > 1 then
		pl:ChatPrint( "You can only add one person to a group at a time!" )
		return 
	end
	target = target[ 1 ]
	if not anus.Groups[ arg[ 1 ] ] or arg[ 1 ] == "user" then
		pl:ChatPrint( "Invalid group supplied" ) 
		return
	end
	if pl:IsTempUser() then
		pl:ChatPrint( "Denied: You're a temporary admin!" )
		return 
	end
	
	local time = arg[ 2 ] 
	if not tonumber( time ) then
		time = anus.ConvertStringToTime( time ) or anus.ConvertStringToTime( "1m" )
		time = math.Clamp( time, 1, ANUS_YEAR )
	else
		time = math.Clamp( tonumber( time ), 1, ANUS_YEAR )
	end
	
	if pl:IsGreaterOrEqualTo( target ) then
		target:SetUserGroup( arg[ 1 ], true, time )
	end
	
	anus.NotifyPlugin( pl, plugin.id, "added ", target, " to group ", COLOR_STRINGARGS, arg[ 1 ], " for ", COLOR_STRINGARGS, anus.ConvertTimeToString( time ), "." )
end


function plugin:GetUsageSuggestions( arg )
	if arg != 2 then return "" end
	
	local output = {}
	for k,v in next, anus.Groups do
		output[ #output + 1 ] = k
	end

	table.SortDesc( output )
	
	local str = ""
	for i=1,#output do
		if #output == i then
			str = str .. output[ i ]
		else
			str = str .. output[ i ] .. ","
		end
	end
	
	return str
end
anus.RegisterPlugin( plugin )

local plugin = {}
plugin.id = "adduseridtemp"
plugin.name = "Add Temp ID User"
plugin.author = "Shinycow"
plugin.usage = "<string:SteamID>; <string:Group>; <string:Time>"
plugin.help = "Temporarily adds a user to a group"
plugin.category = "Utility"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, arg, target )
	if #target > 1 then
		pl:ChatPrint( "You can only add one person to a group at a time!" )
		return 
	end
	if not anus.Groups[ arg[ 2 ] ] or arg[ 2 ] == "user" then
		pl:ChatPrint( "Invalid group supplied" ) 
		return
	end
	if pl:IsTempUser() then
		pl:ChatPrint( "Denied: You're a temporary admin!" )
		return 
	end
	
	local time = arg[ 3 ] 
	if not tonumber( time ) then
		time = anus.ConvertStringToTime( time ) or anus.ConvertStringToTime( "1m" )
		time = math.Clamp( time, 1, ANUS_YEAR )
	else
		time = math.Clamp( tonumber( time ), 1, ANUS_YEAR )
	end
	
	if IsValid( pl ) then
		if anus.GroupHasInheritanceFrom( arg[ 2 ], pl.UserGroup ) then
			pl:ChatPrint( "Unable to add user to group: Group is ranked higher than yours!" )
			return
		end
	end
		
	anus.SetPlayerGroup( arg[ 1 ], arg[ 2 ], time )
	
	anus.NotifyPlugin( pl, plugin.id, "added ", COLOR_STEAMIDARGS, arg[ 1 ], " to group ", COLOR_STRINGARGS, arg[ 2 ], " for ", COLOR_STRINGARGS, anus.ConvertTimeToString( time ), "." )
end


function plugin:GetUsageSuggestions( arg )
	if arg != 2 then return "" end
	
	local output = {}
	for k,v in next, anus.Groups do
		output[ #output + 1 ] = k
	end

	table.SortDesc( output )
	
	local str = ""
	for i=1,#output do
		if #output == i then
			str = str .. output[ i ]
		else
			str = str .. output[ i ] .. ","
		end
	end
	
	return str
end
anus.RegisterPlugin( plugin )



local plugin = {}
plugin.id = "userallow"
plugin.name = "User Allow"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>; <string:Plugin>; [string:Restrictions]"
plugin.help = "Grants a player access to a command"
plugin.category = "Utility"
plugin.defaultAccess = "owner"

function plugin:OnRun( pl, arg, target )
	if #target > 1 then
		pl:ChatPrint( "You can only target one person at a time" )
		return 
	end
	if pl:IsTempUser() then
		pl:ChatPrint( "Denied: You're a temporary admin!" )
		return 
	end
	
	target = target[ 1 ]
	
	target:GrantPermission( arg[ 1 ] )
	anus.NotifyPlugin( pl, plugin.id, "granted permission ", COLOR_STRINGARGS, arg[ 1 ], " to ", target, "." )
end
anus.RegisterPlugin( plugin )

local plugin = {}
plugin.id = "userallowid"
plugin.name = "User Allow ID"
plugin.author = "Shinycow"
plugin.usage = "<string:SteamID>; <string:Plugin>; [string:Restrictions]"
plugin.help = "Grants a steamid access to a command"
plugin.category = "Utility"
plugin.defaultAccess = "owner"

function plugin:OnRun( pl, arg, target )
	if not string.IsSteamID( arg[ 1 ] ) then
		pl:ChatPrint( "No valid steamid supplied" )
		return 
	end
	if pl:IsTempUser() then
		pl:ChatPrint( "Denied: You're a temporary admin!" )
		return 
	end
	
	anus.GrantPermission( arg[ 1 ], arg[ 2 ] )
	anus.NotifyPlugin( pl, plugin.id, "granted permission ", COLOR_STRINGARGS, arg[ 2 ], " to steamid ", COLOR_STEAMIDARGS, arg[ 1 ], "." )
end
anus.RegisterPlugin( plugin )

local plugin = {}
plugin.id = "userrevoke"
plugin.name = "User Revoke"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>; <string:Plugin>"
plugin.help = "Revokes player access to a command"
plugin.category = "Utility"
plugin.defaultAccess = "owner"

function plugin:OnRun( pl, arg, target )
	if #target > 1 then
		pl:ChatPrint( "You can only target one person at a time" )
		return 
	end
	if pl:IsTempUser() then
		pl:ChatPrint( "Denied: You're a temporary admin!" )
		return 
	end
	
	target = target[ 1 ]

	target:RevokePermission( arg[ 1 ] )
	anus.NotifyPlugin( pl, plugin.id, "revoked permission ", COLOR_STRINGARGS, arg[ 1 ], " to ", target, "." )
end
anus.RegisterPlugin( plugin )

local plugin = {}
plugin.id = "userrevokeid"
plugin.name = "User Revoke ID"
plugin.author = "Shinycow"
plugin.usage = "<string:SteamID>; <string:Plugin>"
plugin.help = "Revokes a player access to a command"
plugin.category = "Utility"
plugin.defaultAccess = "owner"

function plugin:OnRun( pl, arg, target )
	if not string.IsSteamID( arg[ 1 ] ) then
		pl:ChatPrint( "No valid steamid supplied" )
		return 
	end
	if pl:IsTempUser() then
		pl:ChatPrint( "You already have temp admin!" )
		return 
	end
	
	anus.RevokePermission( arg[ 1 ], arg[ 2 ] )
	anus.NotifyPlugin( pl, plugin.id, "revoked permission ", COLOR_STRINGARGS, arg[ 2 ], " to steamid ", COLOR_STEAMIDARGS, arg[ 1 ], "." )
end
anus.RegisterPlugin( plugin )

local plugin = {}
plugin.id = "userdeny"
plugin.name = "User Deny"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>; <string:Plugin>"
plugin.help = "Disallows a player access to a command"
plugin.category = "Utility"
plugin.defaultAccess = "owner"

function plugin:OnRun( pl, arg, target )
	if #target > 1 then
		pl:ChatPrint( "You can only target one person at a time" )
		return 
	end
	if pl:IsTempUser() then
		pl:ChatPrint( "Denied: You're a temporary admin!" )
		return 
	end
	
	target = target[ 1 ]
	
	target:DenyPermission( arg[ 1 ] )
	anus.NotifyPlugin( pl, plugin.id, "denied permission ", COLOR_STRINGARGS, arg[ 1 ], " to ", target, "." )
end
anus.RegisterPlugin( plugin )

local plugin = {}
plugin.id = "userdenyid"
plugin.name = "User Deny ID"
plugin.author = "Shinycow"
plugin.usage = "<string:SteamID>; <string:Plugin>"
plugin.help = "Disallows a steamid access to a command"
plugin.category = "Utility"
plugin.defaultAccess = "owner"

function plugin:OnRun( pl, arg, target )
	if not string.IsSteamID( arg[ 1 ] ) then
		pl:ChatPrint( "No valid steamid supplied" )
		return 
	end
	if pl:IsTempUser() then
		pl:ChatPrint( "Denied: You're a temporary admin!" )
		return 
	end
	
	anus.DenyPermission( arg[ 1 ], arg[ 2 ] )
	anus.NotifyPlugin( pl, plugin.id, "denied permission ", COLOR_STRINGARGS, arg[ 2 ], " to steamid ", COLOR_STEAMIDARGS, arg[ 1 ], "." )
end
anus.RegisterPlugin( plugin )