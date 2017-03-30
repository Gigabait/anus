local tableinsert = table.insert

function anus.findPlayer( arg, argtype, caller, specialpatterns )
	if not arg then return nil end
	local Matched = nil
	local Opposite = false

	local Outputs = {}
	local Temporary = {}
	if not specialpatterns then
		if argtype and ( argtype != "steamname" and argtype != "name" ) then
			for k,v in ipairs( player.GetAll() ) do
				local start,endpos = string.find( v:SteamID(), arg, nil, true )
				if endpos == 0 then continue end
				if start then
					Outputs[ #Outputs + 1 ] = v
				end
			end
			
			goto breakout
		end
		
		local Seperation = string.Explode( ",", arg )
		
		if not argtype or argtype == "name" then
			for k,v in ipairs( player.GetAll() ) do

				if v:Nick():lower() == arg:lower() then
					Outputs[ #Outputs + 1 ] = v
					goto breakout
				end

				for _,newarg in ipairs( Seperation ) do
					local start,endpos = string.find( v:Nick():lower(), newarg:lower(), nil, true )
					if endpos == 0 then continue end
					if start then
						Outputs[ #Outputs + 1 ] = v
					end
				end

			end
		elseif argtype == "steamname" then
			for k,v in ipairs( player.GetAll() ) do

				if v:SteamName():lower() == arg:lower() then
					Outputs[ #Outputs + 1 ] = v
					goto breakout
				end

				for _,newarg in ipairs( Seperation ) do
					local start, endpos = string.find( v:SteamName():lower(), newarg:lower(), nil, true )
					if endpos == 0 then continue end
					if start then
						Outputs[ #Outputs + 1 ] = v
					end
				end

			end
		end
	end
	::breakout::
	if #Outputs == 0 then
		Matched = ""
		if string.sub( arg, 1, 1 ) == "!" then
			Opposite = true
			Matched = "!"
			arg = string.sub( arg, 2 )
		end
	
		if arg == "*" then
			for k,v in ipairs( player.GetAll() ) do
				Temporary[ #Temporary + 1 ] = v
			end
			Matched = Matched .. "*"
		elseif arg == "^" and caller and IsValid( caller ) then
			Temporary[ #Temporary + 1 ] = caller
			Matched = Matched .. "^"
		elseif arg == "@" and caller and IsValid( caller ) and  IsValid( caller:GetEyeTrace().Entity ) and caller:GetEyeTrace().Entity:IsPlayer() then
			Temporary[ #Temporary + 1 ] = caller:GetEyeTrace().Entity
			Matched = Matched .. "@"
		elseif string.sub( arg, 1, 1 ) == "%" and anus.isValidGroup( string.sub( arg, 2 ) ) then
			for k,v in ipairs( player.GetAll() ) do
				if v:checkGroup( string.sub( arg, 2 ) ) then
					Temporary[ #Temporary + 1 ] = v
				end
			end
			Matched = Matched .. arg
		elseif string.sub( arg, 1, 1 ) == "#" then
			for k,v in ipairs( player.GetAll() ) do
				if v:IsUserGroup( string.sub( arg, 2 ) ) then
					Temporary[ #Temporary + 1 ] = v
				end
			end
			Matched = Matched .. arg
		end
		
		if Opposite then
			if #Temporary > 0 then
				for k,v in ipairs( player.GetAll() ) do
					for a,b in ipairs( Temporary ) do
						if a == #Temporary and b != v then
							Outputs[ #Outputs + 1 ] = v
						else
							if b == v then break end
						end
					end
				end
			else
				for k,v in ipairs( player.GetAll() ) do
					Outputs[ #Outputs + 1 ] = v
				end
			end
		else
			Outputs = Temporary
		end
	else
		Matched = arg:lower()
	end

	if #Outputs == 0 then return nil end
	if #Outputs > 1 then
		return Outputs, Matched
	else
		return Outputs[ 1 ], Matched
	end
end


---local AnusYear = 2026
--local CalculatedLeapYear = ( (AnusYear % 4 == 0 and AnusYear % 100 != 0) or AnusYear % 400 == 0 ) and 365.25 or 365


ANUS_SECOND = 1
ANUS_MINUTE = 60
ANUS_HOUR = 60 * 60
ANUS_DAY = 60 * 60 * 24
ANUS_WEEK = 60 * 60 * 24 * 7
ANUS_MONTH = 60 * 60 * 24 * ( 365.25 / 12 )
ANUS_YEAR = 60 * 60 * 24 * 365.25
  
	-- E.g 1d = 86400 seconds
	-- returns in seconds
local stringfind = string.find
local stringsub = string.sub
function anus.convertStringToTime( str )
	if str == "0" then
		return 0
	end

	local output = 0
	local place = 0
	local lastFound = 0
	while true do
		local startpos, endpos = stringfind( str, "%a", place )
		if not startpos then break end

		local match = stringsub( str, startpos, endpos )
		local sub = nil

		if lastFound == 0 then
			sub = stringsub( str, 1, endpos - 1 )
			if sub == "_" then sub = nil end
		else
			sub = stringsub( str, lastFound + 1, endpos - 1 )
			if sub == "_" then sub = nil end
		end
		lastFound = endpos

		if sub and sub != "" then
			if match == "s" then
				output = output + sub
			elseif match == "m" then
				output = output + ( sub * ANUS_MINUTE )
			elseif match == "h" then
				output = output + ( sub * ANUS_HOUR )
			elseif match == "d" then
				output = output + ( sub * ANUS_DAY )
			elseif match == "w" then
				output = output + ( sub * ANUS_WEEK )
			elseif match == "M" then
				output = output + ( sub * ANUS_MONTH )
			elseif match == "y" then
				output = output + ( sub * ANUS_YEAR )
			end
		end

		place = endpos + 1
	end

	return output != 0 and output or nil
end

	-- converts from seconds
	-- e.g 86400 seconds returns "1 day"

	-- if second argument is true
	-- 86400 will return "1d"
local mathfloor = math.floor
function anus.convertTimeToString( time, convertable )
	if time == 0 then
		return "eternity"
	end

	local output = ""
	local tbl = {}
	local tbl2 = {}
		-- precision errors
		-- ya im a shit coder, get over yourself
	local place = time + 0.0001

	while true do
		if place >= ANUS_YEAR then
			tbl[ #tbl + 1 ] = mathfloor( place / ANUS_YEAR )
			tbl2[ #tbl2 + 1 ] = { "y", "year" }
			place = place - ( ANUS_YEAR * tbl[ #tbl ] )

		elseif place >= ANUS_MONTH then
			tbl[ #tbl + 1 ] = mathfloor( place / ANUS_MONTH )
			tbl2[ #tbl2 + 1 ] = { "M", "month" }
			place = place - ( ANUS_MONTH * tbl[ #tbl ] )

		elseif place >= ANUS_WEEK then
			tbl[ #tbl + 1 ] = mathfloor( place / ANUS_WEEK )
			tbl2[ #tbl2 + 1 ] = { "w", "week" }
			place = place - ( ANUS_WEEK * tbl[ #tbl ] )

		elseif place >= ANUS_DAY then
			tbl[ #tbl + 1 ] = mathfloor( place / ANUS_DAY )
			tbl2[ #tbl2 + 1 ] = { "d", "day" }
			place = place - ( ANUS_DAY * tbl[ #tbl ] )

		elseif place >= ANUS_HOUR then
			tbl[ #tbl + 1 ] = mathfloor( place / ANUS_HOUR )
			tbl2[ #tbl2 + 1 ] = { "h", "hour" }
			place = place - ( ANUS_HOUR * tbl[ #tbl ] )

		elseif place >= ANUS_MINUTE then
			tbl[ #tbl + 1 ] = mathfloor( place / ANUS_MINUTE )
			tbl2[ #tbl2 + 1 ] = { "m", "minute" }
			place = place - ( ANUS_MINUTE * tbl[ #tbl ] )

		elseif place < 60 then
			tbl[ #tbl + 1 ] = mathfloor( place / ANUS_SECOND)
			tbl2[ #tbl2 + 1 ] = { "s", "second" }
			place = place - ( ANUS_SECOND * tbl[ #tbl ] )
		end

		if place < 1 then
			break
		end
	end

	if convertable then
		for k,v in next, tbl do
			output = output .. v .. tbl2[ k ][ 1 ]
		end
	else
		if #tbl == 1 then
			output = tbl[ 1 ] .. " " .. string.NiceNumber( tbl[ 1 ], tbl2[ 1 ][ 2 ] )
		else
			for k,v in next, tbl do
				if k == #tbl then
					output = output .. v .. " " .. string.NiceNumber( v, tbl2[ k ][ 2 ] )
				elseif k == #tbl - 1 then
					output = output .. v .. " " .. string.NiceNumber( v, tbl2[ k ][ 2 ] ) .. " and "
				else
					output = output ..  v .. " " .. string.NiceNumber( v, tbl2[ k ][ 2 ] ) .. ", "
				end
			end
		end
	end

	return output
end



/*------------------------------------------------------------------------------------------------
    chat.AddText([ Player ply,] Colour colour, string text, Colour colour, string text, ... )
    Returns: nil
    In Object: None
    Part of Library: chat
    Available On: Server
------------------------------------------------------------------------------------------------*/
-- Credits to Overv.
-- And MeepDarkness
-- With slight modification by shinycow

local BITS	= 4;

local E_DUN	= 0;
local E_STR	= 1;
local E_COL	= 2;
local function IsColor( obj )
	local need =
	{
		r = true,
		g = true,
		b = true,
		a = true
	}
	for k,v in ipairs( obj ) do
		if need[ k ] then continue end
		return false
	end
	return true
end
if SERVER then
	util.AddNetworkString( "AddText" )

	chat = chat or {}
	local type = type
	function chat.AddText( pl, ... )
		local arg = { ... }

		if pl and not IsValid( pl ) then
				-- literately cancer:
				-- on srcds anything under 151 doesn't even COUNT
			for k,v in ipairs( arg ) do
				if type( v ) == "table" and IsColor( v ) then
					for a,b in next, v do
						if b >= 90 and b < 151 then
							arg[ k ][ a ] = 151
						end
					end
				end
			end
			MsgC( unpack( arg ) )
			MsgC( "\n" )
			return
		end

		net.Start( "AddText" )
		for _, v in ipairs( arg ) do
			if type( v ) == "function" then continue end

			if type( v ) == "string" or type( v ) == "boolean" or type( v ) == "number" then
				net.WriteUInt( E_STR, BITS )
				net.WriteString( tostring( v ) )
			elseif IsColor( v ) then
				net.WriteUInt( E_COL, BITS )
				if not v.r then continue end
				net.WriteUInt( v.r, 8 )
				net.WriteUInt( v.g, 8 )
				net.WriteUInt( v.b, 8 )
				net.WriteUInt( v.a, 8 )
			end
		end
		net.WriteUInt( E_DUN, BITS )
		if pl != nil then
			net.Send( pl )
		else
			net.Broadcast()
		end
	end
else
	net.Receive( "AddText", function()
		local args = {}
		while true do
			local type = net.ReadUInt( BITS )
			if type == E_COL then
				args[ #args + 1 ] = Color( net.ReadUInt( 8 ), net.ReadUInt( 8 ), net.ReadUInt( 8 ), net.ReadUInt( 8 ) )
			elseif type == E_STR then
				args[ #args + 1 ] = net.ReadString()
			elseif type == E_DUN then
				break;
			end
		end
		chat.AddText( unpack( args ) )
	end )
end


if SERVER then
	function anus.createPlayerList( arg, ornotand )
		local output = {}
			-- no, i can't do #arg
		if table.Count( arg ) == 1 then
				-- yes, i have to use a for loop.
			for k,v in next, arg do
				output[ #output + 1 ] = team.GetColor( v:Team() )
				output[ #output + 1 ] = v:Nick()
			end
		else
			for k,v in next, arg do
				if k != #arg then
					output[ #output + 1 ] = team.GetColor( v:Team() )
					output[ #output + 1 ] = v:Nick()
					output[ #output + 1 ] = Color( 255, 255, 255, 255 )
					output[ #output + 1 ] = ", "
				else
					output[ #output + 1 ] = Color( 255, 255, 255, 255 )
					output[ #output + 1 ] = ornotand and "or " or "and "
					output[ #output + 1 ] = team.GetColor( v:Team() )
					output[ #output + 1 ] = v:Nick()
				end
			end
		end

			-- no targets found
		if #output == 0 then
			output[ 1 ] = Color( 255, 255, 255, 255 )
			output[ 2 ] = "nobody"
		end

		return output
	end

		-- is this still even backwards compatible
	function anus.StartPlayerList()
	end
	function anus.EndPlayerList()
	end

	--[[function anus.notifyPlugin( pl, plugin, ... )
		if not pl or not plugin then return end

		local plColor = Color( 191, 255, 127, 255 )
		local plName = "Someone "

		local function ShowFullPlayer()
			if not IsValid( pl ) then
				plColor = Color( 10, 10, 10, 255 )
			else
				plColor = team.GetColor( pl:Team() )
			end
			plName = pl:Nick() .. " "
		end
		local function ShowPlayerID()
			if not IsValid( pl ) then
				plColor = Color( 10, 10, 10, 255 )
				plName = pl:Nick() .. " "
			else
				plColor = Color( 140, 40, 40, 255 )
				plName = "ADMIN " .. pl:getAssignedID() .. " "
			end
		end
		if not anus.getPlugins()[ plugin ].anonymous then
			if GetConVarString( "anus_logecho" ) == "3" then
				ShowPlayer()
			elseif GetConVarString( "anus_logecho" ) == "2" then
				ShowPlayerID()
				-- todo: implement 1 AND 0, right now it just uses 1 (Someone)
			end
		end
		for k,v in next, player.GetAll() do
			if v.anusUserGroup and anus.Groups[ v.anusUserGroup ] and v:hasAccess( "seeusergroups" ) or v == pl then
				ShowFullPlayer()
			end
		end

		local args = { ... }
		local silent = false
		if type( args[ 1 ] ) != "boolean" then
			table.insert( args, 1, plColor )
			table.insert( args, 2, plName )
		else
			silent = true
			
			table.remove( args, 1 )
			table.insert( args, 1, Color( 0, 161, 255, 255 ) )
			table.insert( args, 2, "(SILENT) " )
			table.insert( args, 3, plColor )
			table.insert( args, 4, plName )
		end

		local resultants = {}
		for k,v in next, args do
			local playerlist = {}
			if type( v ) == "table" then
				for a,b in next, v do
					if type( b ) == "Player" then
						playerlist[ #playerlist + 1 ] = b
					end
				end
			end

			if type( v ) == "Player" then
				args[ k ] = { v }
				resultants[ k ] = anus.createPlayerList( { v } )
			elseif #playerlist > 0 then
				resultants[ k ] = anus.createPlayerList( playerlist )
			end
		end

		for k,v in next, resultants do
			local inserted = 0
			for a,b in next, v do
				inserted = inserted + 1
				table.insert( args, k + inserted, b )
			end
		end

		for k,v in next, args do
			if type( v ) != "table" and type( args[ k - 1 ] ) == "string" or type( args[ k - 1 ] ) == "number" then
				table.insert( args, k, color_white )
			end
		end

		--PrintTable( args )

		for k,v in next, player.GetAll() do
			if silent and not v:hasAccess( "silentnotification" ) then continue end

			chat.AddText( v, unpack( args ) )
		end

		local resultant_string = ""
		for k,v in next, args do
			if type( v ) == "table" then continue end

			resultant_string = resultant_string .. "" .. v
		end

		anus.serverLog( resultant_string )
	end]]
	local AnusLogEcho = nil
	function anus.notifyPlugin( pl, plugin, ... )
		if not pl or not plugin then return end
		if not AnusLogEcho then
			AnusLogEcho = GetConVar( "anus_logecho" )
		end

		local Args = { ... }
		local Silent = false
		local Players = {}
		local CustomOutputs = nil
		local AnonymousColor = Color( 191, 255, 127, 255 )
		local AnonymousName = "Someone"
		local IDColor = Color( 196, 82, 114, 255 )

		if AnusLogEcho and AnusLogEcho:GetString() != "0" then
			if isbool( Args[ 1 ] ) and Args[ 1 ] then
				for k,v in ipairs( player.GetAll() ) do
					if v:hasAccess( "seesilentEchoes" ) then
						Players[ #Players + 1 ] = v
					end
				end

				Silent = true

				table.remove( Args, 1 )
			else
				Players = player.GetAll()
			end
		end

		if AnusLogEcho and AnusLogEcho:GetString() == "1" then
			CustomOutputs = {}

			for k,v in ipairs( Players ) do
				if not v:hasAccess( "seeanonymousEchoes" ) then
					CustomOutputs[ v ] = { AnonymousColor, AnonymousName }
				end
			end
		elseif AnusLogEcho and AnusLogEcho:GetString() == "2" then
			CustomOutputs = {}

			for k,v in ipairs( Players ) do
				if not v:hasAccess( "seeanonymousEchoes" ) then
					CustomOutputs[ v ] = { IDColor, "ADMINID " .. pl:getAssignedID() }
				end
			end
		end

		local Resultants = {}
		for k,v in ipairs( Args ) do
			local PlayerList = {}
			if type( v ) == "table" then
				for a,b in next, v do
					if type( b ) == "Player" then
						PlayerList[ #PlayerList + 1 ] = b
					end
				end
			end

			if type( v ) == "Player" then
				Args[ k ] = { v }
				Resultants[ k ] = anus.createPlayerList( { v } )
			elseif #PlayerList > 0 then
				Resultants[ k ] = anus.createPlayerList( PlayerList )
			end
		end

		for k,v in next, Resultants do
			local Inserted = 0
			for a,b in next, v do
				Inserted = Inserted + 1
				table.insert( Args, k + Inserted, b )
			end
		end

		for k,v in next, Args do
			if type( v ) != "table" and type( Args[ k - 1 ] ) == "string" or type( Args[ k - 1 ] ) == "number" then
				table.insert( Args, k, color_white )
			end
		end

		for k,v in ipairs( Players ) do
			--[[if Silent then
				table.insert( Args, 1, Color( 0, 161, 255, 255 ) )
				table.insert( Args, 2, "(SILENT) " )
			end]]

			local ArgsCopied = table.Copy( Args )

			if Silent then
				table.insert( ArgsCopied, 1, Color( 0, 161, 255, 255 ) )
				table.insert( ArgsCopied, 2, "(SILENT) " )
			end
			
			if not CustomOutputs or not CustomOutputs[ v ] then

				local PlColor = IsValid( pl ) and team.GetColor( pl:Team() ) or Color( 10, 10, 10, 255 )
				local PlName = pl:Nick() .. " "

				table.insert( ArgsCopied, Silent and 3 or 1, PlColor )
				table.insert( ArgsCopied, Silent and 4 or 2, PlName )
				table.insert( ArgsCopied, Silent and 5 or 3, color_white )

				chat.AddText( v, unpack( ArgsCopied ) )

			else

				local PlColor = CustomOutputs[ v ][ 1 ]
				local PlName = CustomOutputs[ v ][ 2 ] .. " "

				table.insert( ArgsCopied, Silent and 3 or 1, PlColor )
				table.insert( ArgsCopied, Silent and 4 or 2, PlName )
				table.insert( ArgsCopied, Silent and 5 or 3, color_white )

				chat.AddText( v, unpack( ArgsCopied ) )

			end
		end

		local OutputString = pl:Nick() .. " "
		for k,v in next, Args do
			if istable( v ) or isbool( v ) then continue end

			OutputString = OutputString .. "" .. v
		end

		anus.serverLog( OutputString )
	end

	function anus.playerNotification( pl, ... )
		local Args = { ... }

		local Resultants = {}

		table.insert( Args, 1, Color( 0, 127, 127, 255 ) )
		table.insert( Args, 2, "[ANUS] " )

		local OrNotAnd = false
		for k,v in next, Args do
			local PlayerList = {}
			if type( v ) == "table" then
				for a,b in next, v do
					if type( b ) == "Player" then
						PlayerList[ #PlayerList + 1 ] = b
					end
				end
			end
			
			if type( v ) == "boolean" and v == true and ( type( Args[ k + 1 ] ) == "table" or type( Args[ k + 1 ] ) == "Player" ) then
				OrNotAnd = true
			end

			if type( v ) == "Player" then
				Args[ k ] = { v }
				Resultants[ k ] = anus.createPlayerList( { v }, OrNotAnd )
			elseif #PlayerList > 0 then
				Resultants[ k ] = anus.createPlayerList( PlayerList, OrNotAnd )
			end
		end

		--local nargs = {}
		for k,v in next, Resultants do
			local Inserted = 0
			for a,b in next, v do
				Inserted = Inserted + 1
				table.insert( Args, k + Inserted, b )
			end
		end
		
		for k,v in next, Args do
			if type( v ) != "table" and type( Args[ k - 1 ] ) == "string" or type( Args[ k - 1 ] ) == "number" then
				table.insert( Args, k, color_white )
			end
			
			if type( v ) == "boolean" and ( (type( Args[ k + 1 ] ) == "table" and Args[ k + 1 ][ 1 ] and type( Args[ k + 1 ][ 1 ] ) == "Player") or type( Args[ k + 1 ] ) == "Player" ) then
				table.remove( Args, k )
			end
		end

		chat.AddText( pl, unpack( Args ) )
	end
	anus.notifyPlayer = anus.playerNotification

end

function anus.debugNotify( msg )
	local Info = debug.getinfo( 2, "S" )
	print( "[anus] DEBUG: " .. msg, Info.short_src .. " : " .. Info.linedefined .. " - " .. Info.lastlinedefined )
end