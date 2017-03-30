anus.Groups = anus.Groups or {}
anus.pluginsTable = {}
anus.Bans = anus.Bans or {}
anus.Users = anus.Users or {}
anus.tempUsers = anus.tempUsers or {}
anus.Colors = {}
anus.Colors.String = Color( 180, 180, 255, 255 )
anus.Colors.SteamID = Color( 191, 255, 127, 255 )
_R = debug.getregistry()

concommand.Add( "anus_reload", function( pl )
	if pl.AnusReloadDelay and pl.AnusReloadDelay > CurTime() then return end
	pl.AnusReloadDelay = CurTime() + 2
	if not pl:IsSuperAdmin() then
		pl:SendLua( [[include( "autorun/client/anus_load.lua" )]] )
		pl:ChatPrint( "Successfully reloaded anus. (cl)" )
		return
	end

	include( "autorun/server/anus_load.lua" )
	--AddCSLuaFile( "autorun/client/anus_load.lua" )
	hook.Call( "anus_AddonReloaded", nil )

	timer.Simple( 0.1, function() file.CreateDir( "anus" ) end )
	timer.Simple( 0.15, function() file.CreateDir( "anus/users" ) end )

	--[[if anus.getPlugins() then
		anus.LoadPlugins()
	else
		print( "ANUS NOT LOADING PLUGINS." )
	end]]

	pl:ChatPrint( "Successfully reloaded anus." )
	print( pl:Nick() .. " reloaded anus." )
end)

AddCSLuaFile( "init_sh.lua" )
AddCSLuaFile( "shortcuts/shortcuts_sh.lua" )
AddCSLuaFile( "extensions/string.lua" )
AddCSLuaFile( "utility/util_sh.lua" )
AddCSLuaFile( "commands/autocomplete_cl.lua" )
AddCSLuaFile( "commands/consolecommands_sh.lua" )   
AddCSLuaFile( "base_cl.lua" )
AddCSLuaFile( "extensions/player_cl.lua" )
AddCSLuaFile( "networking/playerdata_cl.lua" )
AddCSLuaFile( "networking/playerdisconnects_sh.lua" )
AddCSLuaFile( "voting/voting_cl.lua" )
AddCSLuaFile( "networking/filereload_sh.lua" )
AddCSLuaFile( "menu/init_cl.lua" )

include( "init_sh.lua" )
include( "configsourcebans.lua" )
include( "shortcuts/shortcuts_sh.lua" )
include( "extensions/string.lua" )
include( "utility/util_sv.lua" )
include( "utility/util_sh.lua" )
include( "commands/chatcommands_sv.lua" )
include( "commands/consolecommands_sh.lua" )
include( "base_sv.lua" )
include( "extensions/entity_sv.lua" )
include( "extensions/player_sv.lua" )
include( "networking/playerdata_sv.lua" )
include( "networking/playerdisconnects_sh.lua" )
include( "voting/voting_sv.lua" )
include( "networking/filereload_sh.lua" )
include( "menu/init_sv.lua" )

hook.Add( "Initialize", "anus_CreateFolders", function()
	file.CreateDir( "anus" )

	timer.Simple( 0.1, function()
		file.CreateDir( "anus/users" )
		file.CreateDir( "anus/logs" )
		file.CreateDir( "anus/debuglogs" )
		file.CreateDir( "anus/plugins" )
	end )

	if anus.pluginsTable then
		anus.loadPlugins()
	else
		print( "ANUS NOT LOADING PLUGINS." )
	end
end )

local anusdevs =
{
[ "STEAM_0:0:29257121" ] = true
} 
 
function _R.Player:isAnusDev()
	return anusdevs[ self:SteamID() ]
end

MsgC( Color( 255, 0, 0, 255 ), "[ANUS] Prepared and ready to go.\n" )