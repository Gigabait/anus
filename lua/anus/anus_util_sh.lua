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

	-- doesn't support tables in the table
function table.SortIntoIncrement( tbl, member )
	--[[local tbl2 = table.Copy(tbl)
	
	local value
	local tbl3 = {}
	for k,v in pairs(tbl2) do
		--if v[ member ] > 
		--tbl2[ member ] = { member = k }
		value = {k}
		tbl3 = table.Copy(value)
		print(tbl3)
		k = member
		tbl2[ k ][ member ] = "test"
	end]]

		-- i dont know why this is neccessary im not even overriding the original table but w/e
	local tbl2 = table.Copy( tbl )
	local tbl3 = {}
	for k,v in pairs(tbl2) do
		tbl3[ v[ member ] ] = v
		tbl3[ v[ member ] ][ member ] = k
	end
	
	return tbl3
end

function string.NiceName( input )
	if not input then return "" end
	if tonumber(input) then return input end
	
	local sub1 = string.sub( input, 1, 1 )
	local sub2 = string.sub( input, 2, #input )
	
	return sub1:upper() .. sub2
end

/*------------------------------------------------------------------------------------------------
    chat.AddText([ Player ply,] Colour colour, string text, Colour colour, string text, ... )
    Returns: nil
    In Object: None
    Part of Library: chat
    Available On: Server
------------------------------------------------------------------------------------------------*/
	// Credits to Overv.
--[[if ( SERVER ) then
	util.AddNetworkString( "AddText" )

	chat = chat or {}
    function chat.AddText( ... )
		local arg = {...}
        if ( type( arg[1] ) == "Player" ) then
			ply = arg[1] 
		end
		
		if ply and not IsValid(ply) then
			ply = nil
		end
		
		--print(#arg)
		
		net.Start( "AddText" )
			net.WriteUInt( #arg, 12 )
			for _, v in pairs( arg ) do
				if type( v ) == "string" then
					print( v )
					net.WriteString( v )
				elseif type( v ) == "table" then
					if not v.r then continue end
						-- yeah um, this shit's weird. half the time it adds an extra character and i dont know why.. lol
						-- 16 should work fine but i seem to have to keep increasing the #
					net.WriteUInt( math.Clamp(v.r, 0, 255), 8 )
					net.WriteUInt( math.Clamp(v.g, 0, 255), 8 )
					net.WriteUInt( math.Clamp(v.b, 0, 255), 8 )
					net.WriteUInt( math.Clamp(v.a, 0, 255), 8 )
				end
			end
		if ply != nil then
			net.Send( ply )
		else
			net.Broadcast()
		end
    end
else	
	net.Receive( "AddText", function()
		local argc = net.ReadUInt( 12 )
		local args = {}
		for i=1, argc / 2, 1 do
			args[ #args + 1 ] = Color( net.ReadUInt( 8 ), net.ReadUInt( 8 ), net.ReadUInt( 8 ), net.ReadUInt( 8 ) )
			local strings = net.ReadString()
			--print( tostring(i) .. ": " .. strings)
			strings = string.gsub(strings, ".%z", "")
			args[ #args + 1 ] = strings
		end
		
		chat.AddText( unpack( args ) )
	end )
end]]

	

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
			if type( obj ) != "table" then
				print( obj )
			end
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
	end
			
end

function anus.DebugNotify( msg )
	local info = debug.getinfo( 2, "S" )
	print( "[anus] DEBUG: " .. msg, info.short_src .. " : " .. info.linedefined .. " - " .. info.lastlinedefined )
end
