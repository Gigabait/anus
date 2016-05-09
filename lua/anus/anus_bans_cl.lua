net.Receive( "anus_broadcastbans", function( len )
	--local chunks = net.ReadUInt( 8 )
	local bantype = net.ReadUInt( 2 )
	
	if bantype == 0 then
		local chunk = net.ReadUInt( 8 )
		local amt = net.ReadUInt( 18 )
		
		if chunk == 1 then
			anus.Bans = {}
		end
		
		--print( net.ReadString() )
		--print( "amt", amt )
		
		for i=1,amt do
			anus.Bans[ net.ReadString() ] = { name = net.ReadString(), reason = net.ReadString(), time = net.ReadString(), admin = net.ReadString(), admin_steamid = net.ReadString() }
		end
		
		hook.Call( "OnBanlistChanged" )
	elseif bantype == 1 then
		local steamid = net.ReadString()
		
		anus.Bans[ steamid ] = { name = net.ReadString(), reason = net.ReadString(), time = net.ReadString(), admin = net.ReadString(), admin_steamid = net.ReadString() }
	
		hook.Call( "OnBanlistChanged", nil, bantype, steamid )
	elseif bantype == 2 then	
		local steamid = net.ReadString()
			
		anus.Bans[ steamid ] = nil

		hook.Call( "OnBanlistChanged", nil, bantype, steamid )
	end
end )
