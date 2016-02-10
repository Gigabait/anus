local filename = anus.GetFileName(debug.getinfo(1, "S").short_src)

-- May 27, 2014 - i dont even think this file is needed lol

print([[------------------------------
------------------------------
	ANUS - ]] .. filename .. [[
	
------------------------------
------------------------------]])

GROUP_ALL = 1
GROUP_ADMIN = 2
GROUP_SUPERADMIN = 3
GROUP_OWNER = 4

concommand.Add("anus_reload", function( pl )
	if not pl:IsSuperAdmin() then return end
	
	--anus = nil
	include("autorun/sh_load.lua" )
	
	timer.Simple(0.1, function() file.CreateDir("anus") end)
	timer.Simple(0.15, function() file.CreateDir("anus/users") end)
	
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