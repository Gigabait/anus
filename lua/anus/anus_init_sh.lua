local filename = anus.GetFileName(debug.getinfo(1, "S").short_src)

print([[------------------------------
------------------------------
	ANUS - ]] .. filename .. [[
	
------------------------------
------------------------------]])

COLOR_STRINGARGS = Color( 180, 180, 255, 255 )
COLOR_STEAMIDARGS = Color( 191, 255, 127, 255 )

concommand.Add("anus_reload", function( pl )
	if not pl:IsSuperAdmin() then return end
	
	--anus = nil
	include("autorun/sh_load.lua" )
	
	timer.Simple(0.1, function() file.CreateDir("anus") end)
	timer.Simple(0.15, function() file.CreateDir("anus/users") end)
	
	hook.Call( "inherit", nil )
	
	if anus.Plugins then
		anus.LoadPlugins()
	else
		print("ANUS NOT LOADING PLUGINS.")
	end

	pl:ChatPrint("Successfully reloaded anus.")
end)

include("anus_util_sh.lua")
include("anus_groups_sh.lua")
include("anus_plugins_sh.lua")

if SERVER then
	AddCSLuaFile("anus_util_sh.lua")
	AddCSLuaFile("anus_groups_sh.lua")
	AddCSLuaFile("anus_plugins_sh.lua")
end