anus = anus or {}

gameevent.Listen( "player_connect" )
gameevent.Listen( "player_disconnect" )

--[[if not oldinclude then
	oldinclude = include
	function include( str )
		local override = str
	
		local exists = file.Exists( "anus/" .. str, "LUA" )
		if exists then
			override = "anus/" .. str
		end
			
		oldinclude( override )
	end
end]]

include( "anus/init_cl.lua" )