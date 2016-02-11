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
			for k,v in pairs( anus.Plugins ) do
				if LocalPlayer().PlayerInfo and LocalPlayer().PlayerInfo[ LocalPlayer() ]["perms"][ k ] then
					output[ #output + 1 ] = "anus " .. k
					if anus.Plugins[ k ].usage then
						--[[local explodeusage = string.Explode( ";", anus.Plugins[ k ].usage )
						for k,v in pairs(explodeusage) do
							explodeusage[ k ] = string.gsub( v, "%A", "" )
						end 
						
						if explodeusage[1] == "Player" then]]
							
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
			
			--PrintTable( explodeargs )

			for k,v in pairs( anus.Plugins ) do
				if LocalPlayer().PlayerInfo and LocalPlayer().PlayerInfo[ LocalPlayer() ]["perms"][ k ] then
			
						-- command.
					if anus.Plugins[ explodeargs[1]:lower() ] then
						if explodeargs[1]:lower() != k then continue end
							
						if anus.Plugins[ k ].usage then
							local explodeusage = string.Explode( ";", anus.Plugins[ k ].usage )
							--PrintTable( explodeusage )
							for k,v in pairs(explodeusage) do
								--explodeusage[ k ] = string.gsub( v, "%A", "" )
								
								
								local str = v--"player:Player"
								local pattern = "([%a=]+)"
								local start, endpos, word = string.find( str, pattern )
								--print( start, endpos, word )
							
								explodeusage[ k ] = word
							end
								
							if explodeusage[1] == "player" then
								for a,b in pairs(player.GetAll()) do
									if explodeargs[ 2 ] and not string.find(string.lower(b:Nick()), explodeargs[ 2 ]) then continue end
									output[ #output + 1 ] = "anus " .. k .. " \"" .. b:Nick() .. "\""
										-- if there's more than one usage option, display them.
									if #explodeusage > 1 then
										local explodeusageCOPY = string.Explode( ";", anus.Plugins[ k ].usage )
												-- not needed?
										table.remove(explodeusageCOPY, 1)
										for x,y in pairs( explodeusageCOPY ) do
											if anus.Plugins[ k ].GetUsageSuggestions then
												--print( x, y )
												local ynew = string.gsub( y, ">", " (" .. anus.Plugins[ k ]:GetUsageSuggestions( 1 + 1 ) .. ")>" )
												ynew = string.gsub( ynew, "]", " (" .. anus.Plugins[ k ]:GetUsageSuggestions( 1 + 1 ) .. ")]" )
												output[ #output ] = output[ #output ] .. " " .. ynew --y .. " (" .. anus.Plugins[ k ]:GetUsageSuggestions( 1 + 1 ) .. ")"
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
									--table.remove( explodeusageCOPY, 1 )
									for x,y in pairs( explodeusageCOPY ) do
										output[ #output ] = output[ #output ] .. " " .. y
									end
								end
							end
							
						end			
					elseif string.find( k, explodeargs[1]:lower() ) then
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
		concommand.Add("anus", function( p, c, a )
			if not a[1] and CLIENT then chat.AddText( Color( 255, 255, 255, 255 ), "Looking for some guidance? Try \"anus help\"" ) return end

			local cmd = a[1]
			table.remove( a, 1 )
			
			RunConsoleCommand( "anus_" .. cmd, unpack( a ))
		end, CLIENT and anus_AutoComplete)
	end
	
	function anus.AddCommand( info, tbl_autocomplete, func, chatcmd )
		if SERVER then
		
			if type(info) == "table" then
				local function run( p, c, a )
					if not p:HasAccess( info.id ) then p:ChatPrint( "Insufficient access!" ) return end
					if not a then return end
					for k,v in pairs( a ) do
						if #v == 0 then
							a[ k ] = "\""
						end
					end
					
					if info.usage then
						--[[local target = NULL
						if not a[1] then
							--anus.DebugNotify( "no arg[1], sh_load.lua" )
							if string.sub(info.usage, 1, 1) != "[" or not IsValid(p) then p:ChatPrint( info.id .. ": " .. (info.help or "No arguments found.") .. " - " .. info.usage ) return end
							
							target = p
						end
						if not IsValid(target) and not anus.FindPlayer( a[1] ) and not anus.FindPlayer( a[1], "steam") and not anus.Plugins[info.id].notarget then 
							anus.DebugNotify( "no args found? no player i think" )
							p:ChatPrint( info.id .. ": " .. (info.help or "No arguments found.") .. " - " .. info.usage )
							return 
						end

						if anus.Plugins[info.id].notarget then
							info.OnRun( self, p, a, nil )
						else
							local target = IsValid(target) and target or anus.FindPlayer( a[1] )
							if not target then target = anus.FindPlayer( a[1], "steam" ) end
						
							local args = a
							table.remove(args, 1)
							
							info.OnRun( self, p, args, target )
						end]]
						
							-- finally adding support for commands with no player targets
						
						local target = NULL
						
						if not a[1] then
							--anus.DebugNotify( "no arg[1], sh_load.lua" )
							if string.sub(info.usage, 1, 1) != "[" or not IsValid(p) then p:ChatPrint( info.id .. ": " .. (info.help or "No arguments found.") .. " - " .. info.usage ) return end
							
							target = p
						end
						
						local explodeusage = string.Explode( ";", anus.Plugins[ info.id ].usage )
						
						local hasPlayerTarg = false
					
						for k,v in pairs( explodeusage ) do
							
							local str = v 
							local pattern = "([%a=]+)"
							local start, endpos, word = string.find( str, pattern )
							
							explodeusage[ k ] = word
							
							if word == "player" then
								hasPlayerTarg = true
							end
						
						end
						
						if hasPlayerTarg and not IsValid( target ) and not anus.FindPlayer( a[ 1 ] ) and not anus.FindPlayer( a[ 1 ], "steam" ) and not anus.Plugins[ info.id ].notarget then
							p:ChatPrint( info.id .. ": " .. (info.help or "No arguments found.") .. " - " .. info.usage )
							return
						end
						
						if anus.Plugins[info.id].notarget or not hasPlayerTarg then
							info.OnRun( self, p, a, nil )
						else
							local target = IsValid(target) and target or anus.FindPlayer( a[1] )
							if not target then target = anus.FindPlayer( a[1], "steam" ) end
						
							local args = a
							table.remove(args, 1)
							
							info.OnRun( self, p, args, target )
						end
						
						
					else
						if not a[1] then p:ChatPrint( info.id .. ": " .. (info.help or "No arguments found.") .. ((info.usage and " - " .. info.usage) or "") ) return end
					
						info.OnRun( self, p, a, nil )
					end
				end
				
				concommand.Add( "anus_" .. info.id, function( p, c, a )
					run( p, c, a )
				end )
				
				if info.chatcommand then
					chatcommand.Add( info.chatcommand, function( p, c, a )
						run( p, c, a )
					end )
				end
			end
			
		end
	end
	function anus.RemoveCommand( name )
		if SERVER then
			if type( name ) == "table" then
				concommand.Remove( "anus_" .. name.id )
			else
				concommand.Remove( "anus_" .. name )
			end
		end
	end
	anus.DeleteCommand = anus.RemoveCommand
	

if CLIENT then
	include("anus/anus_init_cl.lua")
	include("anus/anus_init_sh.lua")
	include("anus/anus_util_sh.lua")
	include("anus/anus_bans_cl.lua")
	include("anus/anus_groups_sh.lua")
	include("anus/anus_player_cl.lua")
	include("anus/anus_plugins_sh.lua")
	include("anus/skins/anus.lua")
	include("anus/skins/anus_actual.lua")
	include("anus/vgui/anus_mainmenu.lua")
	include("anus/newvgui/anus_mainmenu.lua")
	--[[include("vgui/anus_bansmenu.lua")
	include("vgui/anus_pluginsmenu.lua")
	include("vgui/anus_groupsmenu.lua")]]
end

local function ReloadPlugins()
	if anus.Plugins then
		anus.LoadPlugins()
	else
		print("ANUS NOT LOADING PLUGINS.")
	end
end


hook.Add("Initialize", "anus_LoadThings", function()
	if SERVER then
		file.CreateDir("anus")
		timer.Simple(0.1, function() file.CreateDir("anus/users") end)
	end
	
	ReloadPlugins()
end)

local _R = debug.getregistry()
function _R.Player:IsDev()
	return anusdevs[ self:SteamID() ] or self:SteamID() == "STEAM_0:0:0"
	--return false
end


	