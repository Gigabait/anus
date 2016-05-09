local plugin = {}
plugin.id = "map"
plugin.name = "Map"
plugin.author = "Shinycow"
plugin.usage = "<string:Map>; [number:Time]"
plugin.help = "Changes the map"
plugin.example = "!map gm_flatgrass"
plugin.category = "Utility"
plugin.chatcommand = "map"
plugin.defaultAccess = "superadmin"
plugin.hasDataFolder = true

function plugin:OnRun( pl, args, target )

	if not anus_maps[ args[ 1 ] ] then
		pl:ChatPrint( "Map \"" .. args[ 1 ] .. "\" was not found." )
		return
	end
	local time = args[ 2 ] and math.Clamp( args[ 2 ], 0, 5*60 ) or 0
	
	if time != 0 then
		anus.NotifyPlugin( pl, plugin.id, "is changing the map to ", COLOR_STRINGARGS, args[ 1 ], color_white, " in ", COLOR_STRINGARGS, time, " seconds." )
	else
		anus.NotifyPlugin( pl, plugin.id, "changed the map to ", COLOR_STRINGARGS, args[ 1 ] )
	end
		-- Give it time to notify players.
	timer.Create( "anusChangeMap", 0.5 + time, 1, function()
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

if SERVER then
	function plugin:OnLoad()
		gathermaps()
	end
end

if SERVER then
	util.AddNetworkString( "anus_requestmaps" )
	util.AddNetworkString( "anus_sendmaps" )
	net.Receive( "anus_requestmaps", function( len, pl )
		if pl.LastRequestMap and pl.LastRequestMap > CurTime() then return end
		
		net.Start( "anus_sendmaps" )
			net.WriteUInt( table.Count( anus_maps ), 8 )
			for k,v in next, anus_maps do
				net.WriteString( k )
				net.WriteFloat( anus_mappopularity[ k ] and anus_mappopularity[ k ] or 0 )
			end
		net.Send( pl )
		
		pl.LastRequestMap = CurTime() + 5
	end )
else
	net.Receive( "anus_sendmaps", function()
		anus_maps = {}

		local count = net.ReadUInt( 8 )
		for i=1,count do
			anus_maps[ net.ReadString() ] = math.Round( net.ReadFloat(), 2 )
		end
	end )
end
			

anus.RegisterPlugin( plugin )
if SERVER then
	anus.RegisterHook( "InitPostEntity", "map", function()
		gathermaps()
		
		/*local*/ anus_mappopularitysaveable = {}
		local total = 1
		anus_mappopularity = {}
		
		anus_mappopularitysaveable[ game.GetMap() ] = total
		
		local fileShort = "anus/plugins/" .. plugin.id .. "/popularity.txt"
		if file.Exists( fileShort, "DATA" ) then
			local data = von.deserialize( file.Read( fileShort, "DATA" ) )
			
			for k,v in next, data do
				if k == game.GetMap() then
					anus_mappopularitysaveable[ k ] = v + 1
				else
					anus_mappopularitysaveable[ k ] = --[[( anus_mappopularitysaveable[ k ] and anus_mappopularity[ k ] or 0 ) +]] v
				end
				total = total + v
			end
		end
		
		for k,v in next, anus_mappopularitysaveable do
			anus_mappopularity[ k ] = ( v / total ) * 100
		end
		
		timer.Simple( 0.1, function()
			file.Write( "anus/plugins/" .. plugin.id .. "/popularity.txt", von.serialize( anus_mappopularitysaveable ) )
		end )
		
	end, plugin.id )
end