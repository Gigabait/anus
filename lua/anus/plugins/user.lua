local plugin = {}
plugin.id = "adduser"
plugin.name = "Add User"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>; <string:Group>"
	-- groups opens a dcombox of groups
plugin.args = {"Groups"}
plugin.help = "Adds a user to a group"
plugin.category = "Utility"
plugin.defaultAccess = GROUP_SUPERADMIN

function plugin:OnRun( pl, args, target )
	if type(target) == "table" then pl:ChatPrint("You can only add one person to a group at a time!") return end
	if not args[1] or not anus.Groups[ args[1] ] then pl:ChatPrint("You have to give the right group!") return end
	if anus.TempUsers[ pl:SteamID() ] then pl:ChatPrint("You already have temp admin!") return end
	if IsValid(pl) then
		if anus.Groups[ pl.UserGroup ].id < anus.Groups[ args[1] ].id then pl:ChatPrint("You can't set players to a higher group than yours!") return end
	end
	
	if pl:IsGreaterOrEqualTo( target ) then
		target:SetUserGroup( args[1], true )
		if anus.TempUsers[ target:SteamID() ] then anus.TempUsers[ target:SteamID() ] = nil end
	end

	anus.NotifyPlugin( pl, plugin.id, color_white, "added ", team.GetColor( target:Team() ), target:Nick(), color_white, " to group ", COLOR_STRINGARGS, args[ 1 ] )
end

function plugin:GetUsageSuggestions( arg )
	if arg != 2 then return "" end
	
	local output = {}
	for k,v in pairs( anus.Groups ) do
		output[ #output + 1 ] = k
	end

	--return output
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
plugin.defaultAccess = GROUP_SUPERADMIN

function plugin:OnRun( pl, args, target )
	if type(target) == "table" then pl:ChatPrint("You can only add one person to a group at a time!") return end
	if not args[2] or not anus.Groups[ args[2] ] then pl:ChatPrint("You have to give the right group!") return end
	if anus.TempUsers[ pl:SteamID() ] then pl:ChatPrint("You already have temp admin!") return end
	if IsValid(pl) then
		if anus.Groups[ pl.UserGroup ].id < anus.Groups[ args[2] ].id then pl:ChatPrint("You can't set players to a higher group than yours!") return end
	end
	
	local steamid = args[1]
	
	if not string.match( steamid, "STEAM_0:[0-1]:[0-9]+" ) then
		pl:ChatPrint("This isn't a valid steamid.")
		return
	end
		
	for k,v in pairs(player.GetAll()) do
		if v:SteamID() == steamid then
			pl:Chatrint("You can't use this command on a player who is in the server! Use anus adduserid instead!")
		end
	end
		
	anus.SetPlayerGroup( steamid, args[2] )
	
	anus.NotifyPlugin( pl, plugin.id, color_white, "added steamid ", COLOR_STEAMIDARGS, steamid, color_white, " to group ", COLOR_STRINGARGS, args[ 2 ] )
end

function plugin:GetUsageSuggestions( arg )
	print( "test" )
	if arg != 2 then return "" end
	
	local output = {}
	for k,v in pairs( anus.Groups ) do
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
plugin.usage = "<player:Player>; <string:Group>; <number:Time>"
	-- Int;Minimum;Maximum;AllowDecimals
		-- 4th is optional
plugin.args = {"Groups", "Int;1;300;false"}
plugin.help = "Adds a user to a group for a time in minutes"
plugin.category = "Utility"
plugin.defaultAccess = GROUP_SUPERADMIN

function plugin:OnRun( pl, args, target )
	if type(target) == "table" then pl:ChatPrint("You can only add one person to a group at a time!") return end
	if not args[1] or not anus.Groups[ args[1] ] or args[1] == "user" then pl:ChatPrint("You have to give the right group!") return end
	if anus.TempUsers[ pl:SteamID() ] then pl:ChatPrint("You already have temp admin!") return end
	
	local time = args[2] and math.Clamp(tonumber(args[2]), 1, 300) or 10
	
	if pl:IsGreaterOrEqualTo( target ) then
		target:SetUserGroup( args[1], true, time )
	end
	
	anus.NotifyPlugin( pl, plugin.id, color_white, "added ", team.GetColor( pl:Team() ), target:Nick(), color_white, " to group ", COLOR_STRINGARGS, args[ 1 ], color_white, " for ", COLOR_STRINGARGS, time .. " minutes", color_white, "." )
end


function plugin:GetUsageSuggestions( arg )
	if arg != 2 then return "" end
	
	local output = {}
	for k,v in pairs( anus.Groups ) do
		output[ #output + 1 ] = k
	end

	--return output
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