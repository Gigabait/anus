local plugin = {}
plugin.id = "map"
plugin.chatcommand = { "!map" }
plugin.name = "Map"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Map = "string" },
	{ Time = "number", 10 }
}
plugin.optionalarguments = 
{
	"Time"
}
plugin.description = "Changes the map"
plugin.example = "!map gm_flatgrass"
plugin.category = "Utility"
plugin.noCmdMenu = true
plugin.defaultAccess = "superadmin"
plugin.hasDataFolder = true

function plugin:OnRun( caller, map, time )

	if not anus_maps[ map:lower() ] then
		caller:ChatPrint( "Map \"" .. map .. "\" was not found." )
		return
	end
	time = time and math.Clamp( time, 0, 5*60 ) or 0
	
	if time != 0 then
		anus.notifyPlugin( caller, plugin.id, "is changing the map to ", anus.Colors.String, map, " in ", anus.Colors.String, time, " seconds." )
		timer.Create( "anusChangeMapNotification", 0.3 + time, 1, function()
			if not IsValid( caller ) then return end
			
			anus.notifyPlugin( caller, plugin.id, "changed the map to ", anus.Colors.String, map )
		end )
	else
		anus.notifyPlugin( caller, plugin.id, "changed the map to ", anus.Colors.String, map )
	end
		-- Give it time to notify players.
	timer.Create( "anusChangeMap", 0.5 + time, 1, function()
		RunConsoleCommand( "changelevel", map )
	end )

end

function plugin:GetCustomSuggestions( args )
	local output = {}
	
	if args[ 1 ] then
		for k,v in next, anus_maps do
			if string.find( k:lower(), args[ 1 ]:lower() ) then
				output[ #output + 1 ] = k
			end
		end
	end
	
	return output
end

local function gathermaps()
	anus_maps = {}
	
	local maps = file.Find( "maps/*.bsp", "GAME" )
	for k,v in next, maps do
		anus_maps[ string.StripExtension( v ):lower() ] = k
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
			

anus.registerPlugin( plugin )
if SERVER then
	anus.registerHook( "InitPostEntity", "map", function()
		gathermaps()
		
		local anus_mappopularitysaveable = {}
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
					anus_mappopularitysaveable[ k ] = v
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
else
	anus.registerHook( "InitPostEntity", "map", function()
		net.Start( "anus_requestmaps" )
		net.SendToServer()
	end, plugin.id )
end


local plugin = {}
plugin.id = "cancelmap"
plugin.chatcommand = { "!cancelmap" }
plugin.name = "Cancel Map"
plugin.author = "Shinycow"
plugin.description = "Cancels a map change in progress."
plugin.category = "Utility"
plugin.defaultAccess = "superadmin"
	// todo: implement
plugin.pluginDependent = "map"

function plugin:OnRun( caller )
	if not timer.Exists( "anusChangeMap" ) then
		anus.playerNotification( caller, "There is no pending map change." )
		return
	end
	
	timer.Remove( "anusChangeMap" )
	timer.Remove( "anusChangeMapNotification" )
	anus.notifyPlugin( caller, plugin.id, "canceled the upcoming map change." )
end

anus.registerPlugin( plugin )