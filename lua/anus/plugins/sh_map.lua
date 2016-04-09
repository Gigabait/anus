local plugin = {}
plugin.id = "map"
plugin.name = "Map"
plugin.author = "Shinycow"
plugin.usage = "<string:Map>"
plugin.help = "Changes the map"
plugin.example = "!map gm_flatgrass"
plugin.category = "Utility"
plugin.chatcommand = "map"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, args, target )

	if not anus_maps[ args[ 1 ] ] then
		pl:ChatPrint( "Map \"" .. args[ 1 ] .. "\" was not found." )
		return
	end
	
	anus.NotifyPlugin( pl, plugin.id, "changed the map to ", COLOR_STRINGARGS, args[ 1 ],  color_white, "." )
		-- Give it time to notify players.
	timer.Create( "anusChangeMap", 1, 1, function()
		RunConsoleCommand( "changelevel", args[ 1 ] )
	end )

end

local function gathermaps()
	anus_maps = {}
	
	local maps = file.Find( "maps/*.bsp", "GAME" )
	for k,v in next, maps do
		anus_maps[ string.StripExtension( v ) ] = k
	end
end

function plugin:OnLoad()
	gathermaps()
end

anus.RegisterPlugin( plugin )
anus.RegisterHook( "InitPostEntity", "map", function()
	gathermaps()
end, plugin.id )