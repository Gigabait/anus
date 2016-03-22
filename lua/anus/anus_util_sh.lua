function anus.FindPlayer( arg, argtype )
	if not arg then return nil end
	
	local outputs = {}
	if not argtype or argtype == "name" then
		for k,v in next, player.GetAll() do
			if string.lower(v:Nick()):find( arg:lower(), nil, true ) then
				outputs[ #outputs + 1 ] = v
			end
		end
	else
		for k,v in next, player.GetAll() do
			if string.find(v:SteamID():lower(), arg:lower(), nil, true ) then
				outputs[ #outputs + 1 ] = v
			end
		end
	end
	if arg == "*" and #outputs == 0 then
		for k,v in pairs(player.GetAll()) do
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
	if tonumber(input) then return input end
	
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
	
	

ANUS_SECOND = 1
ANUS_MINUTE = 60
ANUS_HOUR = 60 * 60
ANUS_DAY = 60 * 60 * 24
ANUS_WEEK = 60 * 60 * 24 * 7
ANUS_MONTH = 60 * 60 * 24 * 31
ANUS_YEAR = 60 * 60 * 24 * 31 * 11.7741935

	-- E.g 1d = 86400 seconds
	-- returns in seconds
function anus.ConvertStringToTime( str )
	--print( "start converting: " .. str )
	
	local output = 0
	local place = 0
	local lastFound = 0
	while true do
		local startpos, endpos = string.find( str, "%a", place )
		if not startpos then break end
		
		local match = string.sub( str, startpos, endpos )
		
		--print( startpos, endpos, match, place )
		
		local sub = nil
		
		if lastFound == 0 then
			sub = string.sub( str, 1, endpos - 1 )
			--lastFound = endpos
			--print( "last found ... " .. lastFound )
		else
			sub = string.sub( str, lastFound + 1, endpos - 1 )
			--sub = string.sub( str, startpos - place, endpos - (place + 1) )
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
		
	--print( "OUTPUT: " .. output )
		
	return output != 0 and output or nil
end

	-- converts from seconds
	-- e.g 86400 seconds returns "1 day"
function anus.ConvertTimeToString( time )
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
			tbl[ #tbl + 1 ] = math.floor( place / ANUS_YEAR )
			tbl2[ #tbl2 + 1 ] = "year"
			place = place - ( ANUS_YEAR * tbl[ #tbl ] )
			
		elseif place >= ANUS_MONTH then
			tbl[ #tbl + 1 ] = math.floor( place / ANUS_MONTH )
			tbl2[ #tbl2 + 1 ] = "month"
			place = place - ( ANUS_MONTH * tbl[ #tbl ] )
			
		elseif place >= ANUS_WEEK then
			tbl[ #tbl + 1 ] = math.floor( place / ANUS_WEEK )
			tbl2[ #tbl2 + 1 ] = "week"
			place = place - ( ANUS_WEEK * tbl[ #tbl ] )
			
		elseif place >= ANUS_DAY then
			tbl[ #tbl + 1 ] = math.floor( place / ANUS_DAY )
			tbl2[ #tbl2 + 1 ] = "day"
			place = place - ( ANUS_DAY * tbl[ #tbl ] )
			
		elseif place >= ANUS_HOUR then
			tbl[ #tbl + 1 ] = math.floor( place / ANUS_HOUR )
			tbl2[ #tbl2 + 1 ] = "hour"
			place = place - ( ANUS_HOUR * tbl[ #tbl ] )
			
		elseif place >= ANUS_MINUTE then
			tbl[ #tbl + 1 ] = math.floor( place / ANUS_MINUTE )
			tbl2[ #tbl2 + 1 ] = "minute"
			place = place - ( ANUS_MINUTE * tbl[ #tbl ] )
			
		elseif place < 60 then
			tbl[ #tbl + 1 ] = math.floor( place / ANUS_SECOND)
			tbl2[ #tbl2 + 1 ] = "second"
			place = place - ( ANUS_SECOND * tbl[ #tbl ] )
		end
		
		if place < 1 then
			break
		end
	end
	
	--PrintTable( tbl )
	--print("\n")
	--PrintTable( tbl2 )
	

	if #tbl == 1 then
		output = tbl[ 1 ] .. " " .. string.NiceNumber( tbl[ 1 ], tbl2[ 1 ] )
	else
		for k,v in next, tbl do
			if k == #tbl then
				output = output .. v .. " " .. string.NiceNumber( v, tbl2[ k ] )
			elseif k == #tbl - 1 then
				output = output .. v .. " " .. string.NiceNumber( v, tbl2[ k ] ) .. " and "
			else
				output = output ..  v .. " " .. string.NiceNumber( v, tbl2[ k ] ) .. ", "
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
	function chat.AddText(ply, ...)
		local arg = {...}

		net.Start( "AddText" )
		for _, v in pairs(arg) do
			if type(v) == "function" then continue end
				
			if(type(v) == "string") or type(v) == "boolean" or type(v) == "number" then
				net.WriteUInt(E_STR, BITS);
				net.WriteString(tostring(v))
			elseif(IsColor(v)) then
				net.WriteUInt(E_COL, BITS);
				if not v.r then continue end
				net.WriteUInt(v.r, 8)
				net.WriteUInt(v.g, 8)
				net.WriteUInt(v.b, 8)
				net.WriteUInt(v.a, 8)
			end
		end
		net.WriteUInt(E_DUN, BITS);
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
			-- if it's not a table then we don't include the player name. meaning yes, you can opt out of this
		if type(args[1]) != "boolean" then
			table.insert( args, 1, plColor )
			table.insert( args, 2, plName )
		else
			table.remove(args, 1)
		end
		
		local resultant = {}
		local place_first = nil
		local place_first2 = nil
		local place_second = nil
		local pl_places = {}
		local white_places = {}
		
		local debug_islist = false
		
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
					debug_islist = true
				end
			end
		end
		
		for k,v in next, pl_places do
			table.insert( args, k, team.GetColor( v:Team() ) )
			args[ k + 1 ] = v:Nick()
		end
		
		local white_places = {}
		for k,v in next, args do
			if type( v ) == "string" and type( args[ k - 1 ] ) != "table" then
				white_places[ #white_places + 1 ] = k
			end
		end

		for k,v in next, white_places do
			table.insert( args, v + (k-1), color_white )
		end
		
		local iLoop = 0
		if #resultant > 0 then
			place_first2 = nil
			place_second = nil
			
			for k,v in next, resultant do
				--table.insert( args, place_first + iLoop, v )
				table.insert( args, 1 + place_first + iLoop, v )
				iLoop = iLoop + 1
			end
		end
		
		for k,v in next, player.GetAll() do
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
