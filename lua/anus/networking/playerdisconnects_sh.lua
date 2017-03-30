if SERVER then
	util.AddNetworkString( "anus_requestdc" )
	util.AddNetworkString( "anus_broadcastdc" )

	anus.playerDC = anus.playerDC or {}

	hook.Add( "PlayerDisconnected", "anus_CatchDisconects", function( pl )
		table.insert( anus.playerDC, 1, { steamid = pl:SteamID(), name = pl:Nick(), kills = pl:Frags(), deaths = pl:Deaths(), time = os.time() } )
		if #anus.playerDC > 50 then
			anus.playerDC[ 51 ] = nil
		end
	end )

	net.Receive( "anus_requestdc", function( len, pl )
		if not pl:hasAccess( "unban" ) then return end

		net.Start( "anus_broadcastdc" )
			net.WriteUInt( #anus.playerDC, 6 )
			for k,v in ipairs( anus.playerDC ) do
				net.WriteString( v.steamid )
				net.WriteString( v.name )
				net.WriteUInt( v.kills, 14 )
				net.WriteUInt( v.deaths, 14 )
				--net.WriteUInt( tostring( v.time ):sub( 2 ), 29 )
					-- less data
				net.WriteString( os.date( "%H:%M:%S", v.time ) )
			end
		net.Send( pl )
	end )
else
	anus.playerDC = anus.playerDC or {}
	net.Receive( "anus_broadcastdc", function()
		anus.playerDC = {} 

		local Amt = net.ReadUInt( 6 )

		for i=1,Amt do
			anus.playerDC[ i ] = { steamid = net.ReadString(), name = net.ReadString(), kills = net.ReadUInt( 14 ), deaths = net.ReadUInt( 14 ), time = net.ReadString() } --time = tonumber( 1 .. net.ReadUInt( 29 ) ) }
		end
		
		hook.Call( "anus_FinishedDisconnectedPlayers", nil )
	end )
end