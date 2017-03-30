--ANUS_PARENTFILE = "anus/init_cl.lua" 

if CLIENT or SERVER then
	concommand.Add( "anus", function( p, c, a, sargs )
		if not a[ 1 ] and CLIENT then
			chat.AddText( Color( 255, 255, 255, 255 ), "Looking for some guidance? Try \"anus help\"" )
			return
		elseif not a[ 1 ] and SERVER then
			print( "Looking for some guidance? Try \"anus help\"" )
			return
		end

		local LCmd = string.lower( a[ 1 ] )

		if anus.cvarsRegistered[ LCmd ] then
			if a[ 2 ] and #a[ 2 ]:Trim() > 0 then
				RunConsoleCommand( "anus_ChangeCVarSetting", LCmd, a[ 2 ] )
			else
				RunConsoleCommand( "anus_" .. LCmd )
			end
			-- backwards compatibility
		elseif util.NetworkStringToID( "anus_ccplugin_" .. LCmd ) == 0 or not sargs then
			local Cmd = a[ 1 ]

			if not concommand.GetTable()[ "anus_" .. Cmd ] then
				p:PrintMessage( HUD_PRINTCONSOLE, "Unknown command: anus " .. Cmd .. "\nNeed help? try \"anus help\"\n" )
				return
			end

			table.remove( a, 1 )

			RunConsoleCommand( "anus_" .. Cmd, unpack( a ) )
		else
			if anus.getPlugins()[ LCmd ] and anus.getPlugins()[ LCmd ].disabled  then
				p:PrintMessage( HUD_PRINTCONSOLE, "Unknown command: anus " .. LCmd .. "\nNeed help? try \"anus help\"\n" )
				return
			end

			sargs = sargs:gsub( a[ 1 ], "", 1 )
			sargs = sargs:TrimLeft()

			if CLIENT then
				net.Start( "anus_CCPlugin_" .. LCmd )
					net.WriteString( sargs )
				net.SendToServer()
			else
				if not _G[ "anus" ][ "RunCommand_" .. LCmd ] then return end
				_G[ "anus" ][ "RunCommand_" .. LCmd ]( p, c, a, sargs )
			end
		end

	end, CLIENT and anus_AutoComplete )
end

local function ReturnFoundType( strtype, strfind, numarg, tblargs, plcaller )
	if strtype == "player" then
		local Output = nil
		Output = anus.findPlayer( strfind, "name", plcaller )
		Output = Output != nil and Output or anus.findPlayer( strfind, "steamname", plcaller )
		Output = Output != nil and Output or anus.findPlayer( strfind, "steam", plcaller )
		if strfind == "" then Output = nil end

		return type( Output ) != "table" and { Output } or Output, Output == nil and "Couldn't find any player(s)" or nil
	elseif strtype == "number" then
		strfind = tonumber( strfind )

		if not strfind then
			return nil, "Incorrect argument passed (#" .. ( numarg or "unknown" ) .. ") - Number expected"
		end

		return strfind
	elseif strtype == "time" then
		if anus.convertStringToTime( strfind ) then
			strfind = anus.convertStringToTime( strfind )
		else
			strfind = tonumber( strfind )
		end

		if not strfind then
			return nil, "Incorrect argument passed (#" .. ( numarg or "unknown" ) .. ") - Time expected"
		end

		return strfind
	elseif strtype == "boolean" then
		if not tblargs[ numarg + 1 ] and tblargs[ numarg ] == " " then
			return nil, "Incorrect argument passed  (#" .. ( numarg or "unknown" ) ..") - Boolean expected"
		end
			-- tobool considers "nil" true
			-- https://github.com/garrynewman/garrysmod/blob/master/garrysmod/lua/includes/util.lua#L221
		if strfind == "nil" then return false end
		return tobool( strfind )
	elseif strtype == "string" then
		return strfind
	end
end

local function SpecialPlayerRunAbility( plcaller, numarg, returndata, value )
	local Output = {}

	local Data = anus.findPlayer( value, nil, plcaller, true )
	
	if isentity( Data ) then
		for k,v in ipairs( returndata ) do
			if v == Data then
				Output[ 1 ] = v
				break
			end
		end
	else
		for k,v in ipairs( returndata ) do
			for a,b in ipairs( Data or {} ) do
				if v == b then
					Output[ #Output + 1 ] = v
				end
			end
		end
	end
	
	if #Output == 0 then
		return false, "Arg #" .. ( numarg or "unknown" ) .. ": You can't target these players"
	end
	
	return true, Output
end
local function VerifyPlayerRunAbility( plcaller, pluginid, specialaccess, returndata, strtype, numarg )--, tblargs )
	if not SERVER then return end
	
		-- put the commented code below into the Run function
	
	
	-- the numbers/time/player/boolean/string should already be verified with above function before running this function
	
	if not IsValid( plcaller ) then return true end
	
	local fallbackCanTarget = false
	
	if specialaccess then
		if specialaccess == true or specialaccess == "true" then return true end
		if specialaccess == "false" or specialaccess == "false" then return false, "Not allowed" end
	else
			-- add a target
		if anus.getGroups()[ plcaller:GetUserGroup() ].Permissions[ pluginid ] == true or anus.getGroups()[ plcaller:GetUserGroup() ].Permissions[ pluginid ] == "true" then
			if strtype == "player" then
				fallbackCanTarget = true
			else
				return true
			end
		end
		if anus.getGroups()[ plcaller:GetUserGroup() ].Permissions[ pluginid ] == false or anus.getGroups()[ plcaller:GetUserGroup() ].Permissions[ pluginid ] == "false" then return false, "Not allowed" end
	end
	
		-- gotta do similar with how i parse commands
		-- stuff like restricting kick reasons to such like "no bots allowed" won't work here.
	local Exploded = specialaccess and specialaccess or anus.Groups[ plcaller:GetUserGroup() ].Permissions[ pluginid ]
	if not Exploded then return false, "Error occured" end
	Exploded = not fallbackCanTarget and string.Explode( " ", Exploded ) or {}

		local Value = Exploded[ numarg ] != nil and Exploded[ numarg ] or Exploded[ #Exploded ]
		if fallbackCanTarget then
			Value = anus.getGroups()[ plcaller:GetUserGroup() ].can_target
			return SpecialPlayerRunAbility( plcaller, numarg, returndata, Value )
		end 
		
		if (strtype == "number" or strtype == "time") then
			local ColonFound = string.find( Value, ":" )
			local MinNum
			local MaxNum
			
			if ColonFound and ColonFound != 1 and (ColonFound + 1 <= #Value) then
				MinNum = string.sub( Value, 1, ColonFound - 1 )
				MaxNum = string.sub( Value, ColonFound + 1, #Value )
			elseif ColonFound then
				if #Value == 1 then
					return true
				elseif ColonFound == 1 then
					MinNum = string.sub( Value, ColonFound + 1, #Value )
					MaxNum = MinNum
				elseif ColonFound + 1 > #Value then
					MinNum = string.sub( Value, 1, ColonFound - 1 )
					MaxNum = MinNum
				end
			else
				if not tonumber( Value ) then return true end
					
				MinNum = tonumber( Value )
				MaxNum = tonumber( Value ) 
			end

			if string.find( MinNum, "%a" ) then
				anus.convertStringToTime( MinNum )
			elseif string.find( MaxNum, "%a" ) then
				anus.convertStringToTime( MaxNum )
			end
			if returndata < tonumber( MinNum ) then
				return false, "Arg #" .. ( numarg or "unknown" ) .. " has number less than min allowed (Allowed " .. tonumber( MinNum ) .. ")"
			elseif returndata > tonumber( MaxNum ) then
				return false, "Arg #" .. ( numarg or "unknown" ) .. " has number greater than max allowed (Allowed " .. tonumber( MaxNum ) .. ")"
			end
		elseif strtype == "boolean" then
			if tobool( Value ) != returndata then
				return false, "Arg #" .. ( numarg or "unknown" ) .. " expected boolean value of " .. Value
			end
		elseif strtype == "string" then
				-- SHINYCOW: incorporate ability to replace %steamid% with calling player's steamid
		
			if (string.sub( Value, 1, 1 ) == "<") and (string.sub( Value, #Value ) == ">") then
				local StringToExplode = string.sub( Value, 2, #Value - 1 )
				local WhitelistedTable = string.Explode( ",", StringToExplode )
				local FoundString = false
				
				--print( "returndata", returndata )
				for k,v in ipairs( WhitelistedTable ) do
					if returndata == v then
						--print( returndata, v )
						FoundString = true
					end
				end
				
				if not FoundString then
					return false, "Arg #" .. ( numarg or "unknown" ) .. ": Got non-whitelisted string"
				end
			else
				if Value != returndata then
					return false, "Arg #" .. ( numarg or "unknown" ) .. ": Got non-whitelisted string"
				end
			end
		elseif strtype == "player" then
			local Explode = string.Explode( ",", Value )
			local Output = {}

			for k,v in ipairs( Explode ) do
				local Opposite = false
				if string.sub( v, 1, 1 ) == "!" then
					Opposite = true
				end
				
				local Data = anus.findPlayer( v, nil, plcaller, true )

				if isentity( Data ) then
					for k,v in ipairs( returndata ) do
						if v == Data then
							Output[ #Output + 1 ] = v
						end
					end
				else
					for k,v in ipairs( returndata ) do
						for a,b in ipairs( Data or {} ) do
							if v == b then Output[ #Output + 1 ] = v end
						end
					end
				end
			end
			
			if #Output == 0 then
				return false, "Arg #" .. ( numarg or "unknown" ) .. ": You can't target these players"
			end
			
			return true, Output
		end
	
	
	
	return true
	
	
	/*local PluginArgs = anus.getPlugin( pluginid ).arguments
	
		-- Player has been registered with special permissions with this plugin
	if not IsValid( plcaller ) then return true end

	if specialaccess then

		if specialaccess == "true" then return true end
		if specialaccess == "false" then return false, "Not allowed" end
	
		local Exploded = string.Explode( " ", specialaccess )
		
		for k,v in ipairs( Exploded ) do
				-- check if it's a number/time
				-- < and > denotes strings allowed
			if (strtype == "number" or strtype == "time") and string.find( v, ":" ) and not string.find( v, "<" ) and v != ":" then
				local ColonFound = string.find( v, ":" )
				local MinNum = string.sub( v, 1, ColonFound - 1 )
				local MaxNum = string.sub( v, ColonFound + 1, #v )

				if string.find( MinNum, "%a" ) then
					anus.convertStringToTime( MinNum )
				elseif string.find( MaxNum, "%a" ) then
					anus.convertStringToTime( MaxNum )
				end

				if returndata < tonumber( MinNum ) then
					return false, "Arg #" .. ( numarg or "unknown" ) .. " has number less than min allowed (Allowed " .. MinNum .. ")"
				elseif returndata > tonumber( MaxNum ) then
					return false, "Arg #" .. ( numarg or "unknown" ) .. " has number greater than max allowed (Allowed " .. MaxNum .. ")"
				end
				
				-- explicit strings allowed
			elseif string.find( v, "<" ) and string.find( v, ">" ) then
				print( "V....", v )
				local StringToExplode = string.sub( v, 2, #v - 1 )
				local ExplodeThatString = string.Explode( ",", StringToExplode )
				local Found = false
				for a,b in ipairs( ExplodeThatString ) do
					if tostring( returndata ) == b then
						print( "ayee" )
						Found = true
					else
						print( returndata, "oh no" )
					end
				end
				
				if not Found then
					return false, "Arg #" .. ( numarg or "unknown" ) .. " has non-whitelisted string"
				end
			end
		end

	else
		
		if anus.Groups[ plcaller:GetUserGroup() ].Permissions[ pluginid ] == true then return true end
		if anus.Groups[ plcaller:GetUserGroup() ].Permissions[ pluginid ] == false then return false, "Not allowed" end
		
		local Exploded = string.Explode( " ", anus.Groups[ plcaller:GetUserGroup() ].Permissions[ pluginid ] )
		
		for k,v in ipairs( Exploded ) do
				-- check if it's a number/time
				-- < and > denotes strings allowed
			if string.find( v, ":" ) and not string.find( v, "<" ) and v != ":" then
				local ColonFound = string.find( v, ":" )
				local MinNum = string.sub( v, 1, ColonFound - 1 )
				local MaxNum = string.sub( v, ColonFound + 1, #v )
				
				if string.find( MinNum, "%a" ) then
					anus.convertStringToTime( MinNum )
				elseif string.find( MaxNum, "%a" ) then
					anus.convertStringToTime( MaxNum )
				end
				
				if returndata < MinNum then
					return false, "Arg #" .. ( numarg or "unknown" ) .. " has number less than min allowed (" .. MinNum .. ")"
				elseif returndata > MaxNum then
					return false, "Arg #" .. ( numarg or "unknown" ) .. " has number greater than max allowed (" .. MaxNum .. ")"
				end
				
				-- explicit strings allowed
			elseif string.find( v, "<" ) and string.find( v, ">" ) then
				local ExplodeThatString = string.Explode( ",", v )
				local Found = false
				for a,b in ipairs( ExplodeThatString ) do
					if tostring( returndata ) == b then
						Found = true
					end
				end
				
				if not Found then
					return false, "Arg #" .. ( numarg or "unknown" ) .. " has non-whitelisted string"
				end
			end
		end
		
	end
	
	return true*/
end


function anus.addCommand( info, tbl_autocomplete, func, chatcmd )
	if not SERVER or not istable( info ) then return end

	local next = next
	local isstring = isstring
	local istable = istable
	local isentity = isentity
	local tonumber = tonumber
	local IsValid = IsValid
		-- this function used to be an absolute mess
		-- now its a slightly smaller mess
	--[[local function Run( p, c, a, sargs)
		if not a then return end
		if not p:hasAccess( info.id ) then
			p:ChatPrint( "Access denied!" )
			return
		end

		if sargs then
			if string.sub( sargs, 1, 8 ) == "anus_lua" or string.sub( sargs, 1, 8 ) == "anus lua" then
				p:ChatPrint( "You cannot run lua from rcon!" )
				return
			elseif string.sub( sargs, 1, 19 ) == "anus_pluginload lua" or string.sub( sargs, 1, 19 ) == "anus pluginload lua" then
				p:ChatPrint( "Lua plugin may only be enabled through server console." )
				return
			elseif c == "anus_pluginload" and string.sub( sargs, 1, 3 ) == "lua" and IsValid( p ) then
				p:ChatPrint( "Lua plugin may only be enabled through server console." )
				return
			end
		end
		
		--print( sargs )

		if not info.arguments then
			return info.OnRun( self, p )
		end

		local ArgsRequired = (info.arguments and #info.arguments or 0) - (info.optionalarguments and #info.optionalarguments or 0)
		local PlData = {}
		local ErrorMsg = ""
		local ArgsGiven = 0
		for k,v in next, a do
			if #v == 0 then
				a[ k ] = "\""
			end

			if info.arguments[ k ] then
				local Data = nil
				for dataName, dataValue in next, info.arguments[ k ] do
					if isstring( dataName ) then
						Data = dataValue
						break
					end
				end
				local ReturnData, Err = ReturnFoundType( Data, v, k, a, p )

				if Err then
					ErrorMsg = Err
					break
				end
				PlData[ #PlData + 1 ] = ReturnData
			else
				if not istable( PlData[ #PlData ] ) then
					PlData[ #PlData ] = tostring( PlData[ #PlData ] ) .. " " .. v
				else
					if not isentity( PlData[ #PlData ][ 1 ] ) then --type( pldata[ #pldata ][ 1 ] ) != "Player" then
						PlData[ #PlData ] = tostring( PlData[ #PlData ] ) .. " " .. v
					end
				end
			end

			ArgsGiven = ArgsGiven + 1
		end
		
		if ErrorMsg != "" then
			anus.playerNotification( p, ErrorMsg )
			return
		end

		if ArgsGiven < ArgsRequired then
			anus.playerNotification( p, "You have only supplied " .. ArgsGiven .. "/" .. ArgsRequired .." arguments!" )
			return
		end

			-- for optional args
		if ArgsGiven < #info.arguments then
			for k,v in ipairs( info.arguments ) do
				if v[ 1 ] and k > ArgsGiven then
					PlData[ #PlData + 1 ] = v[ 1 ]
				end
			end

			for k,v in ipairs( info.optionalarguments ) do
				for arg,name in ipairs( info.arguments ) do
					if name[ v ] and name[ v ] == "player" then
						if not a[ arg ] and IsValid( p ) then
							PlData[ #PlData + 1 ] = { p }
						elseif not a[ arg ] and not IsValid( p ) then
							anus.playerNotification( p, "You must supply a valid player to run this command!" )
							return
						end
					end
				end
			end
		end
		
		print("\n")
		PrintTable( a )
		print( "\n" )
		PrintTable( PlData )

		return info.OnRun( self, p, unpack( PlData ) )
	end]]
	local function Run( p, c, a, sargs)
		if not a then return end
		local Access, SpecialAccess = p:hasAccess( info.id )
		if not Access then
			p:ChatPrint( "Access denied!" )
			return
		end

		if sargs then
			if string.sub( sargs, 1, 8 ) == "anus_lua" or string.sub( sargs, 1, 8 ) == "anus lua" then
				p:ChatPrint( "You cannot run lua from rcon!" )
				return
			elseif string.sub( sargs, 1, 19 ) == "anus_pluginload lua" or string.sub( sargs, 1, 19 ) == "anus pluginload lua" then
				p:ChatPrint( "Lua plugin may only be enabled through server console." )
				return
			elseif c == "anus_pluginload" and string.sub( sargs, 1, 3 ) == "lua" and IsValid( p ) then
				p:ChatPrint( "Lua plugin may only be enabled through server console." )
				return
			end
		end
		
		--print( sargs )

		if not info.arguments then
			return info.OnRun( self, p )
		end

		local ArgsRequired = (info.arguments and #info.arguments or 0) - (info.optionalarguments and #info.optionalarguments or 0)
		local PlData = {}
		local ErrorMsg = ""
		local ArgsGiven = 0
		local ArgNames = {}
		local ArgsReference = {}
		for k,v in next, a do
			if #v == 0 then
				a[ k ] = "\""
			end
			
			if info.arguments[ k ] then
				local Data = nil
				for dataName, dataValue in next, info.arguments[ k ] do
					ArgNames[ k ] = dataName
					ArgsReference[ #ArgsReference + 1 ] = k
					if isstring( dataName ) then
						Data = dataValue
						break
					end
				end
				--print( "aids", Data, k,  )
				local ReturnData, Err = ReturnFoundType( Data, v, k, a, p, info.id, SpecialAccess )

				if Err then
					ErrorMsg = Err
					break
				end
				
				local CanRun, Returnable = VerifyPlayerRunAbility( p, info.id, SpecialAccess, ReturnData, Data, k )
				
				if not CanRun then
					ErrorMsg = Returnable
					break
				end
				
				if CanRun and Returnable then
					ReturnData = Returnable
				end
				
				if info.argumentsFormatted and info.argumentsFormatted[ ArgNames[ k ] ] then
					PlData[ #PlData + 1 ] = { ReturnData }
				else
					PlData[ #PlData + 1 ] = ReturnData
				end
			else
				local Data = nil
				if info.arguments[ #ArgsReference ] then
					for dataName, dataValue in next, info.arguments[ #ArgsReference ] do
						if isstring( dataName ) then
							Data = dataValue
							break
						end
					end
				end
	
				if not istable( PlData[ #PlData ] ) then
						-- Additional code
						-- Edited for fixing plugins like "!adminmode 15 test"
						-- They get appended.
						-- If something else breaks due to this new code, redo this section and do more concrete looks.
					if not isnumber( PlData[ #PlData ] ) then
						-- ^ end of additional code
						PlData[ #PlData ] = tostring( PlData[ #PlData ] ) .. " " .. v
					end
				else
					if not isentity( PlData[ #PlData ][ 1 ] ) then --type( pldata[ #pldata ][ 1 ] ) != "Player" then
						if info.argumentsFormatted and info.argumentsFormatted[ ArgNames[ #PlData ] ] then
							local CanRun, Returnable = VerifyPlayerRunAbility( p, info.id, SpecialAccess, v, Data, k )
							
							if not CanRun then
								ErrorMsg = Returnable
								break
							end
							
							PlData[ #PlData ][ #PlData[ #PlData ] + 1 ] = v
						else
							PlData[ #PlData ] = tostring( PlData[ #PlData ] ) .. " " .. v
						end
					end
				end
			end

			ArgsGiven = ArgsGiven + 1
		end
		
		if ErrorMsg != "" then
			anus.playerNotification( p, ErrorMsg )
			return
		end

		if ArgsGiven < ArgsRequired then
			anus.playerNotification( p, "You have only supplied " .. ArgsGiven .. "/" .. ArgsRequired .." arguments!" )
			return
		end

			-- for optional args
		if ArgsGiven < #info.arguments then
			for k,v in ipairs( info.arguments ) do
				if v[ 1 ] and k > ArgsGiven then
					PlData[ #PlData + 1 ] = v[ 1 ]
				end
			end

			for k,v in ipairs( info.optionalarguments ) do
				for arg,name in ipairs( info.arguments ) do
					if name[ v ] and name[ v ] == "player" then
						if not a[ arg ] and IsValid( p ) then
							PlData[ #PlData + 1 ] = { p }
						elseif not a[ arg ] and not IsValid( p ) then
							anus.playerNotification( p, "You must supply a valid player to run this command!" )
							return
						end
					end
				end
			end
		end
		
		local CheckForMaxPlayerArg = {}
		for k,v in ipairs( info.arguments ) do
			if not info.arguments[ k ][ 1 ] then continue end

			for a,b in next, v do
				if b == "player" then
					CheckForMaxPlayerArg[ k ] = info.arguments[ k ][ 1 ]
				end
			end
		end
		
		for k,v in next, CheckForMaxPlayerArg do
			if PlData[ k ] and istable( PlData[ k ] ) then
				if #PlData[ k ] > v then
					anus.playerNotification( p, "Arg #" .. k .. " needs to be more specific! Did you mean ", true, PlData[ k ], "?" )
					return
				end
			end
		end

		return info.OnRun( self, p, unpack( PlData ) )
	end
	

	concommand.Add( "anus_" .. info.id, function( p, c, a, sargs )
		if not info.id then return end
		if info.disabled then return end

		Run( p, c, a, sargs )
	end )


	util.AddNetworkString( "anus_CCPlugin_" .. info.id )

		-- this is actually pretty tidy now
		-- still, gl hf
	local function RunCommand( p, strargs )
		local Args = {}

		if not anus.getPlugins()[ info.id ].notarget then
				-- set the placemark where a quote is found, 
				-- will be checked later on to find end of it
			local PlaceFound = nil

			local Value
			for i=1,#strargs do
				Value = strargs[ i ]
				if Value == "\"" then
					HasString = true
					if PlaceFound then
						table.insert( Args, #Args + 1, string.sub( strargs, PlaceFound + 1, i - 1) )
						PlaceFound = nil
					else
						PlaceFound = i
					end
				elseif Value == " " and not PlaceFound and strargs[ i + 1 ] != "\"" then
					Args[ #Args + 1 ] = ""
				else
					if not PlaceFound and strargs[ i - 1 ] != "\"" then
						if #Args - 1 < 0 then
							Args[ #Args + 1 ] = Value
							-- shinycow: dont think this isneeded anymore
						elseif Args[ #Args - 1 ] == " " then
							Args[ #Args + 1 ] = Value
						else
							if V != " " and not placefound then
								Args[ #Args ] = Args[ #Args ] .. Value
							end
						end
					end
				end
			end	
		else
			Args = string.Explode( " ", strargs )
		end
		
		for k,v in next, Args do
				-- the trimming is to fix errors that would occur from running things such as
				-- anus changegroupcolor owner "255 0 0"
			if #Args != 1 then
				Args[ k ] = string.TrimRight( v )
			end
			if #v == 0 and #Args != 1 then
				Args[ k ] = " "
			end
		end
		
		if #Args == 1 and #Args[ 1 ] == 0 then
			Args[ 1 ] = nil
		end

		Run( p, "anus_" .. info.id, Args, strargs )
	end

	_G[ "anus" ][ "RunCommand_" .. info.id ] = function( p, c, a, sargs )
		if info.disabled then return end

		RunCommand( p, sargs )
	end


	net.Receive( "anus_CCPlugin_" .. info.id, function( l, p )
		if not info.id then return end
		if info.disabled then return end

		local StrArgs = net.ReadString()

		RunCommand( p, StrArgs )
	end )


	if info.chatcommand and istable( info.chatcommand ) then
		for k,v in ipairs( info.chatcommand ) do
			chatcommand.Add( v, function( p, c, a, sargs )
				if info.disabled then return end

				return Run( p, c, a, sargs )
			end )
		end
	elseif info.chatcommand then
		chatcommand.Add( info.chatcommand, function( p, c, a, sargs )
			if info.disabled then return end

			return Run( p, c, a, sargs )
		end )
	end
end
function anus.runCommand( plugin, ... )
	if not anus.getPlugins()[ plugin ] or anus.getPlugins()[ plugin ].disabled then return end

	anus.getPlugins()[ plugin ].OnRun( self, ... )
end
function anus.removeCommand( plugin )
	if SERVER then
		plugin = isstring( plugin ) and anus.getPlugins()[ plugin ] or plugin
		concommand.Remove( "anus_" .. plugin.id )
		if plugin.chatcommand and istable( plugin.chatcommand ) then
			for k,v in ipairs( plugin.chatcommand ) do
				chatcommand.Remove( v )
			end
		elseif plugin.chatcommand then
			chatcommand.Remove( plugin.chatcommand )
		end
		_G[ "anus" ][ "RunCommand_" .. plugin.id ] = nil
		net.Receivers[ "anus_ccplugin_" .. plugin.id ] = nil
	end
end
anus.deleteCommand = anus.removeCommand