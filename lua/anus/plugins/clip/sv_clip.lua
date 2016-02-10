util.AddNetworkString("anus_plugins_requestclip")
util.AddNetworkString("anus_plugins_sendclip")

CLIPBOARDS = CLIPBOARDS or {}

net.Receive("anus_plugins_sendclip", function( len, pl )
	if not pl.RequestedClip then return end
	
	CLIPBOARDS[ pl:SteamID() ] = CLIPBOARDS[ pl:SteamID() ] or {}
	CLIPBOARDS[ pl:SteamID() ][ #CLIPBOARDS[ pl:SteamID() ] + 1 ] = {name = pl:Nick(), clipboard = net.ReadString()}
	
	pl.RequestedClip = false
end)

function PLUGIN:OnRun( pl, arg, target )
	if not target and IsValid( pl ) then
		target = pl
	end
		
	if type(target) == "table" then return end
	
	target.RequestedClip = true
	
	net.Start("anus_plugins_requestclip")
	net.Send( target )
	
end
anus.RegisterPlugin( PLUGIN )