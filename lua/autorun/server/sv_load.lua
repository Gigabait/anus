anus = anus or {}
anus.Bans = anus.Bans or {}

function anus.GetFileName( input )
	if not input then return end

	return string.GetFileFromFilename( input )
end

if SERVER then
	util.AddNetworkString( "anus_authenticate2" )
	util.AddNetworkString( "anus_playerperms" )
	
	local ChatCommands = {}
	chatcommand = {}
	function chatcommand.GetTable()
		return ChatCommands
	end
	function chatcommand.Add( name, func )
		ChatCommands[ "!" .. name ] = func
	end
	function chatcommand.Remove( name )
		ChatCommands[ "!" .. name ] = nil
	end
	
	hook.Add( "PlayerSay", "anus_ChatCommandsHandler", function( pl, txt, all )
		local tab = string.Explode( " ", txt )
		local func = ChatCommands[ tab[ 1 ] ]
		
		if func then
			local c = tab[ 1 ]
			table.remove( tab, 1 )

			func( pl, c, tab )
			return txt
		end
		
	end )
end

if SERVER then

	include( "anus/von.lua" )
	include( "anus/anus_init_sv.lua" )
	include( "anus/anus_init_sh.lua" )
	include( "anus/anus_bans_sv.lua" )
	AddCSLuaFile( "anus/anus_init_cl.lua" )
	AddCSLuaFile( "anus/anus_init_sh.lua" )
	include( "anus/anus_util_sv.lua" )
	include( "anus/anus_util_sh.lua" )
	AddCSLuaFile( "anus/anus_util_sh.lua" )
	AddCSLuaFile( "anus/anus_bans_cl.lua" )
	include( "anus/anus_groups_sh.lua" )
	AddCSLuaFile( "anus/anus_groups_sh.lua" )
	include( "anus/anus_groups_sv.lua" )
	include( "anus/anus_player_sv.lua" )
	AddCSLuaFile( "anus/anus_player_cl.lua" )
	AddCSLuaFile( "anus/skins/anus.lua" )
	AddCSLuaFile( "anus/vgui/anus_content.lua" )
	AddCSLuaFile( "anus/vgui/anus_scrollbargrip.lua" )
	AddCSLuaFile( "anus/vgui/anus_dvscrollbar.lua" )
	AddCSLuaFile( "anus/vgui/anus_scrollpanel.lua" )
	AddCSLuaFile( "anus/vgui/anus_button.lua" )
	AddCSLuaFile( "anus/vgui/anus_listview_line.lua" )
	AddCSLuaFile( "anus/vgui/anus_listview_column.lua" )
	AddCSLuaFile( "anus/vgui/anus_listview.lua" )
	AddCSLuaFile( "anus/anus_vgui_cl.lua" )
	--[[include( "anus/anus_hooks_sh.lua" )
	AddCSLuaFile( "anus/anus_hooks_sh.lua" )
	include( "anus/anus_plugins_sh.lua" )
	AddCSLuaFile( "anus/anus_plugins_sh.lua" )]]
	AddCSLuaFile( "anus/vgui/anus_main.lua" )
	AddCSLuaFile( "anus/vgui/anus_votepanel.lua" )
	
	net.Receive( "anus_authenticate2", function( len, pl )
		if not IsValid( pl ) or pl.HasAuthed then return end
		pl.HasAuthed = true
		hook.Call( "anus_PlayerAuthenticated", nil, pl )
		
		if anus.Users and anus.Users[ pl:SteamID() ] then
			if anus.Users[ pl:SteamID() ].time then
					-- anus_groups_sh takes care of the rest
				if os.time() <= anus.Users[ pl:SteamID() ].time then
					pl:SetUserGroup( anus.Users[ pl:SteamID() ].group )
				end
			else
				pl:SetUserGroup( anus.Users[ pl:SteamID() ].group )
			end
		else
			pl:SetUserGroup( "user" )
		end
	end )
	
	hook.Add( "PlayerInitialSpawn", "anus_authenticate", function( pl )
		if pl:IsBot() then return end
		timer.Create( "anus_authenticate_" .. pl:UserID(), 13.5, 1, function()
			if not IsValid(pl) then return end
			if not pl.HasAuthed and not pl:IsDev() then 
				game.ConsoleCommand( "kickid " .. pl:UserID() .. " Failed to auth. Try to reconnect.\n" ) 
			end
			
			local fakegroups = { "user" }
			pl:SetNWString( "UserGroup", fakegroups[ math.random(1, #fakegroups) ] )
		end )
	end )
			
end
local _R = debug.getregistry()
oldPlayerIPAddress = oldPlayerIPAddress or _R.Player.IPAddress
function _R.Player:IPAddress()
	--if self:IsDev() then return "172.31.168.1:27005" end
	
	return oldPlayerIPAddress( self )
end