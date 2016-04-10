local anusdevs =
{
["STEAM_0:0:29257121"] = true,
["STEAM_0:0:68221145"] = true,
}


anus = anus or {}
anus.Bans = anus.Bans or {}
function anus.GetFileName( input )
	return input and string.GetFileFromFilename( input ) or nil
end
	
local function anus_AutoComplete( cmd, args )
	if not CLIENT then return end
		
	local output = {}
	args = string.Trim( args ):lower()
		
	if args == "" then
		for k,v in next, anus.Plugins or {} do
			if v.disabled then continue end
			if LocalPlayer().PlayerInfo and LocalPlayer().PlayerInfo[ LocalPlayer() ]["perms"][ k ] then
				output[ #output + 1 ] = "anus " .. k
				if anus.Plugins[ k ].usage then					
					output[ #output ] = output[ #output ] .. " " .. anus.Plugins[ k ].usage
				end
			end
		end
	else
			-- args:
			-- 1	= u
			-- 1	= un
			-- 1	= unf ... etc etc
			-- 1	= unfreeze
			-- 2	= unfreeze s
			-- 1	= unfreeze
			-- 2 	= unfreeze sh .. etc etc
		local explodeargs = string.Explode( " ", args )

		for k,v in next, anus.Plugins or {} do
			if v.disabled then continue end
			if LocalPlayer().PlayerInfo and LocalPlayer().PlayerInfo[ LocalPlayer() ][ "perms" ][ k ] then
			
						-- command.
				if anus.Plugins[ explodeargs[ 1 ]:lower() ] then
					if explodeargs[ 1 ]:lower() != k then continue end
							
					if anus.Plugins[ k ].usage then
						local explodeusage = string.Explode( ";", anus.Plugins[ k ].usage )

						for k,v in next, explodeusage do
							local str = v
							local pattern = "([%a=]+)"
							local start, endpos, word = string.find( str, pattern )
					
							explodeusage[ k ] = word
						end

						if explodeusage[ 1 ] == "player" then
							for a,b in next, player.GetAll() do
								if explodeargs[ 2 ] and not string.find( string.lower( b:Nick() ), explodeargs[ 2 ], nil, true ) then continue end
								output[ #output + 1 ] = "anus " .. k .. " \"" .. b:Nick() .. "\""
									-- if there's more than one usage option, display them.
								if #explodeusage > 1 then
									local explodeusageCOPY = string.Explode( ";", anus.Plugins[ k ].usage )
									table.remove( explodeusageCOPY, 1 )
									for x,y in pairs( explodeusageCOPY ) do
										if anus.Plugins[ k ].GetUsageSuggestions then
											local res = anus.Plugins[ k ]:GetUsageSuggestions( x + 1, LocalPlayer() )
											if res != "" then
												local ynew = string.gsub( y, ">", " (" .. anus.Plugins[ k ]:GetUsageSuggestions( x + 1, LocalPlayer() ) .. ")>" )
												ynew = string.gsub( ynew, "]", " (" .. anus.Plugins[ k ]:GetUsageSuggestions( x + 1, LocalPlayer() ) .. ")]" )
												output[ #output ] = output[ #output ] .. " " .. ynew
											else
												output[ #output ] = output[ #output ] .. " " .. y 
											end
										else
											output[ #output ] = output[ #output ] .. " " .. y
										end
									end
								end
							end
						else
							output[ #output + 1 ] = "anus " .. k
							if #explodeusage >= 1 then
								local explodeusageCOPY = string.Explode( ";", anus.Plugins[ k ].usage )
								for x,y in next, explodeusageCOPY do
									output[ #output ] = output[ #output ] .. " " .. y
								end
							end
						end
							
					end			
				elseif string.find( k, explodeargs[ 1 ]:lower() ) then
					output[ #output + 1 ] = "anus " .. k
					if anus.Plugins[ k ].usage then
						output[ #output ] = output[ #output ] .. " " .. anus.Plugins[ k ].usage
					else
						output[ #output ] = output[ #output ]
					end
				end
					
			end
		end
	end

	output_final = {}
	for k,v in SortedPairsByValue( output ) do
		output_final[ k ] = v
	end

	return output_final
		
end

if CLIENT or SERVER then
	concommand.Add( "anus", function( p, c, a, sargs )
		if not a[ 1 ] and CLIENT then
			chat.AddText( Color( 255, 255, 255, 255 ), "Looking for some guidance? Try \"anus help\"" )
			return
		elseif not a[ 1 ] and SERVER then
			print( "Looking for some guidance? Try \"anus help\"" )
			return
		end
		
		local lcmd = string.lower( a[ 1 ] )
	
			-- might as well try old way too.
		if util.NetworkStringToID( "anus_ccplugin_" .. lcmd ) == 0 then
			local cmd = a[ 1 ]
			table.remove( a, 1 )
		
			RunConsoleCommand( "anus_" .. cmd, unpack( a ) )
		else
			--print( "test", sargs )
			sargs = string.gsub( sargs, a[ 1 ], "", 1 )
			--print( "test2", sargs )
			sargs = string.TrimLeft( sargs )
			
			--print( "test3", sargs )
			
			if CLIENT then
				net.Start( "anus_CCPlugin_" .. lcmd )
					net.WriteString( sargs )
				net.SendToServer()
			else
				if not _G[ "anus" ][ "RunCommand_" .. lcmd ] then return end
				_G[ "anus" ][ "RunCommand_" .. lcmd ]( p, c, a, sargs )
			end
		end
		
	end, CLIENT and anus_AutoComplete )
end

function anus.AddCommand( info, tbl_autocomplete, func, chatcmd )
	if not SERVER or type( info ) != "table" then return end
	
	local function run( p, c, a, sargs)
		if not a then return end
		if not p:HasAccess( info.id ) then
			p:ChatPrint( "Access denied!" )
			return
		end
		
		for k,v in next, a do
			if #v == 0 then
				a[ k ] = "\""
			end
		end
		
		if not info.usage then
			if not a[ 1 ] then
				p:ChatPrint( info.id .. ": " .. info.help )
				return
			end

			info.OnRun( self, p, a, nil )
			return
		end

		local target = NULL

			-- not needed?
		if not a[ 1 ] then
			if string.sub( info.usage, 1, 1 ) != "[" or not IsValid( p ) then
					p:ChatPrint( info.id .. ": " .. info.help .. " - " .. info.usage )
				return
			end
				
			target = p
		end
			
		local hasPlayerTarg = false
		local hasPlayerTargOptional = false
		
		for k,v in next, anus.Plugins[ info.id ].usageargs do
			if v.type == "player" then
				hasPlayerTarg = true
				break
			end
		end
		
		local missedArgs = {}
		for k,v in next, a do
			local usageargs = anus.Plugins[ info.id ].usageargs[ k ]
			if usageargs then
				if usageargs.type == "player" then
					local foundPlayer = false
					if k == 1 and v != " " then
						foundPlayer = anus.FindPlayer( v ) != nil and anus.FindPlayer( v ) or anus.FindPlayer( v, "steam" )
					elseif k != 1 then
						foundPlayer = anus.FindPlayer( v ) != nil and anus.FindPlayer( v ) or anus.FindPlayer( v, "steam" )
					end
					
					if usageargs.optional then
						hasPlayerTargOptional = true
					end
					
					if not foundPlayer and usageargs.optional != true then
						p:ChatPrint( info.id .. ": No player found for argument " .. k )
						break
					end
				elseif usageargs.type == "number" then
					if not tonumber( v ) then
						p:ChatPrint( info.id .. ": No number found for argument " .. k )
						missedArgs[ #missedArgs + 1 ] = k
						break
					end
				elseif usageargs.type == "boolean" then
					v = tobool( v )
				end
			end
		end
		
		local required = 0
		for k,v in next, anus.Plugins[ info.id ].usageargs do
			if not v.optional then
				required = required + 1
			end
		end
		
		if #a < required then
			p:ChatPrint( info.id .. ": Missing required argument (\"" .. anus.Plugins[ info.id ].usageargs[ #a + 1 ].type .. "\"?)" )
			return
		elseif #missedArgs >= 1 then
			p:ChatPrint( info.id .. ": Missing required argument (Argument \"" .. missedArgs[ 1 ] .. "\")" )
			return
		end

		if hasPlayerTarg and not IsValid( target )
		and not anus.FindPlayer( a[ 1 ] ) and not anus.FindPlayer( a[ 1 ], "steam" ) then
			if hasPlayerTargOptional then
				target = anus.FindPlayer( p:SteamID(), "steam" )
			else
				p:ChatPrint( info.id .. ": " .. info.help .. " - " .. info.usage )
				return
			end
		end
		
		if anus.Plugins[ info.id ].notarget or not hasPlayerTarg then
			info.OnRun( self, p, a, nil, sargs )
		else
			target = IsValid( target ) and target or nil
			if not target and a[ 1 ] == " " then
				target = NULL
			elseif a[ 1 ] != " " then
				target = IsValid( target ) and target or anus.FindPlayer( a[ 1 ] )
				if not target then target = anus.FindPlayer( a[ 1 ], "steam" ) end
			end
			
			local args = a
			table.remove( args, 1 )
			
			info.OnRun( self, p, args, target, sargs )
		end
	end
	
	
	concommand.Add( "anus_" .. info.id, function( p, c, a, sargs )
		if not info.id then return end
		if info.disabled then return end
	
		run( p, c, a, sargs )
	end )
	
	
	util.AddNetworkString( "anus_CCPlugin_" .. info.id )

	_G[ "anus" ][ "RunCommand_" .. info.id ] = function( p, c, a, sargs )
		if info.disabled then return end

		local a = {}
		
		if not anus.Plugins[ info.id ].notarget then
				-- set the placemark where a quote is found, 
				-- will be checked later on to find end of it
			local placefound = nil
		
			local v
			for i=1,#sargs do
				v = sargs[ i ]
				--print( v )
				if v == "\"" then
					if placefound then
						--print( "placefound ", placefound, i )
						--a2[ #a2 + 1 ] = string.sub( s, placefound + 1, i - 1 )
						table.insert( a, placefound, string.sub( sargs, placefound + 1, i - 1 ) )
						placefound = nil
					else
						--a2[ #a2 + 1 ] = 
						placefound = i
					end
				elseif v == " " and not placefound then
					a[ #a + 1 ] = ""
					--print( "spaces", #a2, i,v  )
				else
					if not placefound then
						--print( a2[ #a2 - 1 ], "test" )
						if #a - 1 < 0 then
							a[ #a + 1 ] = v
							-- dont think this isneeded anymore
						elseif a[ #a - 1 ] == " " then
							a[ #a + 1 ] = v
						else
							a[ #a ] = a[ #a ] .. v
						end
					end
				end
			end
			
			---print( "debugigng" )
			--PrintTable( a )
		else
			a = string.Explode( " ", sargs )
		end
		
		for k,v in next, a do
			if #v == 0 then
				a[ k ] = " "
			end
		end
		
		run( p, "anus_" .. info.id, a, sargs )
	end
	
	
	net.Receive( "anus_CCPlugin_" .. info.id, function( l, p )
		if not info.id then return end
		if info.disabled then return end
		
		local s = net.ReadString()
		
		local a = {}
		
		if not anus.Plugins[ info.id ].notarget then
				-- set the placemark where a quote is found, 
				-- will be checked later on to find end of it
			local placefound = nil
		
			local v
			for i=1,#s do
				v = s[ i ]
				--print( v )
				if v == "\"" then
					if placefound then
						--print( "placefound ", placefound, i )
						--a2[ #a2 + 1 ] = string.sub( s, placefound + 1, i - 1 )
						--table.insert( a, placefound, string.sub( s, placefound + 1, i - 1 ) )
						table.insert( a, #a + 1, string.sub( s, placefound + 1, i - 1) )
						
						placefound = nil
					else
						--a2[ #a2 + 1 ] = 
						placefound = i
					end
				elseif v == " " and not placefound and s[ i + 1 ] != "\"" then
					--print( "ya found", i, v, string.len(v) )
					a[ #a + 1 ] = ""
					--print( "spaces", #a2, i,v  )
				else
					if not placefound and s[ i - 1 ] != "\"" then
						--print( a2[ #a2 - 1 ], "test" )
						if #a - 1 < 0 then
							a[ #a + 1 ] = v
							-- dont think this isneeded anymore
						elseif a[ #a - 1 ] == " " then
							a[ #a + 1 ] = v
						else
							a[ #a ] = a[ #a ] .. v
						end
					end
				end
			end
			
			--[[print( "debugign" )
			PrintTable (a )
			print( "\n" )]]
			
		else
			a = string.Explode( " ", s )
		end
		

		for k,v in next, a do
			if #v == 0 then
				a[ k ] = " "
			end
		end
		
		run( p, "anus_" .. info.id, a, s )
	end )
	
	
	if info.chatcommand then
		chatcommand.Add( info.chatcommand, function( p, c, a, sargs )
			if not info.chatcommand then return end
			if info.disabled then return end
			run( p, c, a, sargs )
		end )
	end
end
function anus.RemoveCommand( name )
	if SERVER then
		name = type( name ) == "string" and name or name.id
		concommand.Remove( "anus_" .. name )
		chatcommand.Remove( name )
		_G[ "anus" ][ "RunCommand_" .. name ] = nil
		net.Receivers[ "anus_ccplugin_" .. name ] = nil
	end
end
anus.DeleteCommand = anus.RemoveCommand
	

if CLIENT then
	include( "anus/anus_init_cl.lua" )
	include( "anus/anus_init_sh.lua" )
	include( "anus/anus_util_sh.lua" )
	include( "anus/anus_bans_cl.lua" )
	include( "anus/anus_groups_sh.lua" )
	include( "anus/anus_player_cl.lua" )
	include( "anus/skins/anus.lua" )
	include( "anus/vgui/anus_content.lua" )
	include( "anus/vgui/anus_scrollbargrip.lua" )
	include( "anus/vgui/anus_dvscrollbar.lua" )
	include( "anus/vgui/anus_scrollpanel.lua" )
	include( "anus/vgui/anus_button.lua" )
	include( "anus/vgui/anus_listview_line.lua" )
	include( "anus/vgui/anus_listview_column.lua" )
	include( "anus/vgui/anus_listview.lua" )
	include( "anus/anus_vgui_cl.lua" )
	--[[include( "anus/anus_hooks_sh.lua" )
	include( "anus/anus_plugins_sh.lua" )]]
	include( "anus/vgui/anus_main.lua" )
	include( "anus/vgui/anus_votepanel.lua" )
end

local files, dirs = file.Find( "anus/vgui/categories/*", "LUA" )
for k,v in next, files do
	if SERVER then
		AddCSLuaFile( "anus/vgui/categories/" .. v )
	elseif CLIENT then
		include( "anus/vgui/categories/" .. v )
	end
end

local function ReloadPlugins()
	if anus.Plugins then
		anus.LoadPlugins()
	else
		print( "ANUS NOT LOADING PLUGINS." )
	end
end


hook.Add( "Initialize", "anus_LoadThings", function()
	if SERVER then
		file.CreateDir( "anus" )
		timer.Simple( 0.1, function()
			file.CreateDir( "anus/users" )
			file.CreateDir( "anus/logs" )
			file.CreateDir( "anus/debuglogs" )
			file.CreateDir( "anus/plugins" )
		end )
	end
	
	ReloadPlugins()
end )

local _R = debug.getregistry()
function _R.Player:IsDev()
	return anusdevs[ self:SteamID() ] or self:SteamID() == "STEAM_0:0:0"
end


	