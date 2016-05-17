local player = player
local next = next
local string = string
local tableinsert = table.insert
function anus.FindPlayer( arg, argtype )
	if not arg then return nil end
	
	local outputs = {}
	if not argtype or argtype == "name" then
		for k,v in next, player.GetAll() do
			if string.find( string.lower( v:Nick() ), arg:lower(), nil, true ) then
				outputs[ #outputs + 1 ] = v
			end
		end
	else
		for k,v in next, player.GetAll() do
			if string.find( string.lower( v:SteamID() ), arg:lower(), nil, true ) then
				outputs[ #outputs + 1 ] = v
			end
		end
	end
	if arg == "*" and #outputs == 0 then
		for k,v in next, player.GetAll() do
			outputs[ #outputs + 1 ] = v
		end
	end
	
	if #outputs == 0 then return nil end
	if #outputs > 1 then
		return outputs
	else
		return outputs[ 1 ]
	end
end

function string.NiceName( input )
	if not input then return "" end
	if tonumber( input ) then return input end
	
	local sub1 = string.sub( input, 1, 1 )
	local sub2 = string.sub( input, 2, #input )
	
	return sub1:upper() .. sub2
end

function string.NiceNumber( iNum, string )
	if not iNum or not string then return "" end
	iNum = tonumber( iNum )
	if not iNum then return "" end
	
	if iNum > 1 then
		string = string .. "s"
	end

	return string
end

function string.IsSteamID( steamid )
	local res = string.match( steamid, "STEAM_0:[0-1]:[0-9]+" )
	if not res then return false end
	
	return res
end

ANUS_SECOND = 1
ANUS_MINUTE = 60
ANUS_HOUR = 60 * 60
ANUS_DAY = 60 * 60 * 24
ANUS_WEEK = 60 * 60 * 24 * 7
ANUS_MONTH = 60 * 60 * 24 * (365.25/12)
ANUS_YEAR = 60 * 60 * 24 * 365.25

	-- E.g 1d = 86400 seconds
	-- returns in seconds
local stringfind = string.find
local stringsub = string.sub
function anus.ConvertStringToTime( str )
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
		--print( "match", match )
		
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
function anus.ConvertTimeToString( time, convertable )
	if time == 0 then
		return "eternity"
	end
	
	local output = ""
	local tbl = {}
	local tbl2 = {}
		-- needed the 0.0001
		-- 60 * 60 * 24 * 31 * 11.7741935 is greater than place (precision errors)
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
// Credits to Overv.
// And MeepDarkness
     
local BITS              = 4;

local E_DUN             = 0;
local E_STR             = 1;
local E_COL             = 2;
local function IsColor(obj)
	local need = {
		r = true;
		g = true;
		b = true;
		a = true;
	};
	for k,v in pairs(obj) do
		if(need[k]) then continue; end
		return false;
	end
	return true;
end
if(SERVER) then
           
	util.AddNetworkString("AddText")
     
           
	chat = chat or {}
	local netWriteUInt = net.WriteUInt
	local type = type
	function chat.AddText(ply, ...)
		local arg = {...}

		net.Start( "AddText" )
		for _, v in pairs(arg) do
			if type(v) == "function" then continue end
				
			if(type(v) == "string") or type(v) == "boolean" or type(v) == "number" then
				netWriteUInt(E_STR, BITS);
				net.WriteString(tostring(v))
			elseif(IsColor(v)) then
				netWriteUInt(E_COL, BITS);
				if not v.r then continue end
				netWriteUInt(v.r, 8)
				netWriteUInt(v.g, 8)
				netWriteUInt(v.b, 8)
				netWriteUInt(v.a, 8)
			end
		end
		netWriteUInt(E_DUN, BITS);
		if(ply ~= nil) then
			net.Send(ply)
		else
			net.Broadcast()
		end
	end
else  
	net.Receive("AddText", function()
		local args = {}
		while(true) do
			local type = net.ReadUInt(BITS);
			if(type == E_COL) then
				args[#args + 1] = Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8));
			elseif(type == E_STR) then
				args[ #args + 1 ] = net.ReadString();
			elseif(type == E_DUN) then
				break;
			end
		end
		chat.AddText(unpack(args));
	end);
end


if SERVER then
	local team = team
	function anus.CreatePlayerList( arg )
		local output = {}
			-- no, i can't do #arg
		if table.Count(arg) == 1 then
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
					output[ #output + 1 ] = "and "
					output[ #output + 1 ] = team.GetColor( v:Team() )
					output[ #output + 1 ] = v:Nick()
				end
			end
		end
		
			-- no targets found
		if #output == 0 then
			output[ #output + 1 ] = Color( 255, 255, 255, 255 )
			output[ #output + 1 ] = "nobody"
		end
		
		return output
	end
	
	function anus.StartPlayerList()	
	end
	function anus.EndPlayerList()
	end
	
	function anus.NotifyPlugin( pl, plugin, ... )
		if not pl or not plugin then return end
		
		local plColor = Color( 191, 255, 127, 255 )
		local plName = "Someone "
		
		local function ShowPlayer()
			if not IsValid( pl ) then
				plColor = Color( 10, 10, 10, 255 ) 
			else
				plColor = team.GetColor( pl:Team() )
			end
			plName = pl:Nick() .. " "
		end
		if not anus.Plugins[ plugin ].anonymous then
			ShowPlayer()
		end
		for k,v in next, player.GetAll() do
			if v.UserGroup and anus.Groups[ v.UserGroup ] and anus.Groups[ v.UserGroup ][ "isadmin" ] or v == pl then
				ShowPlayer()
			end
		end
		
		local args = {...}
		local silent = false
			-- if it's not a table then we don't include the player name. meaning yes, you can opt out of this
		--[[if type( args[ 1 ] ) != "boolean" then
			tableinsert( args, 1, plColor )
			tableinsert( args, 2, plName )
		else
			table.remove(args, 1)
		end]]
		if type( args[ 1 ] ) != "boolean" then
			tableinsert( args, 1, plColor )
			tableinsert( args, 2, plName )
		else
			silent = true
			table.remove( args, 1 )
			tableinsert( args, 1, Color( 0, 161, 255, 255 ) )
			tableinsert( args, 2, "(SILENT) " )
			tableinsert( args, 3, plColor )
			tableinsert( args, 4, plName )
			--table.remove(args, 1)
		end
		
		local resultant = {}
		local place_first = nil
		local place_first2 = nil
		local place_second = nil
		local pl_places = {}
		local white_places = {}
		
		for k,v in next, args do	
			if type( v ) == "function" then
				if not place_first then
					place_first = k
					place_first2 = k + 1
				else
					place_second = k
				end
			elseif type( v ) == "Player" then
				pl_places[ k ] = v
			else		
				if place_first and k == (place_first + 1) then
					resultant = anus.CreatePlayerList( v )
				end
			end
		end
		
		for k,v in next, pl_places do
			tableinsert( args, k, team.GetColor( v:Team() ) )
			args[ k + 1 ] = v:Nick()
		end
		
		local white_places = {}
		for k,v in next, args do
			if type( v ) == "string" and type( args[ k - 1 ] ) != "table" then
				white_places[ #white_places + 1 ] = k
			end
		end

		for k,v in next, white_places do
			tableinsert( args, v + (k-1), color_white )
		end
		
		local iLoop = 0
		if #resultant > 0 then
			place_first2 = nil
			place_second = nil
			
			for k,v in next, resultant do
				--table.insert( args, place_first + iLoop, v )
				tableinsert( args, 1 + place_first + iLoop, v )
				iLoop = iLoop + 1
			end
		end
		
		for k,v in next, player.GetAll() do
			if silent and not v:HasAccess( "silentnotification" ) then continue end
			
			chat.AddText( v, unpack( args ) )
		end
		
		local resultant_string = ""
		for k,v in next, args do
			if type( v ) != "string" then continue end
			
			resultant_string = resultant_string .. " " .. v
		end
	
		anus.ServerLog( resultant_string ) 
	end
	
end

function anus.DebugNotify( msg )
	local info = debug.getinfo( 2, "S" )
	print( "[anus] DEBUG: " .. msg, info.short_src .. " : " .. info.linedefined .. " - " .. info.lastlinedefined )
end
