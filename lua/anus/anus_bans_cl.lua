	-- the menu for this stops showing entries at 1100
	-- every 250 results make a new page.
net.Receive( "anus_broadcastbans", function( len )
	--print( "len" , len )
	--[[anus.Bans = {}
	
	local amt = net.ReadUInt( 16 )
	for i=1,amt do
		anus.Bans[ net.ReadString() ] = { name = net.ReadString(), reason = net.ReadString(), time = net.ReadString(), admin = net.ReadString(), admin_steamid = net.ReadString() }
	end]]
	
	local chunks = net.ReadUInt( 8 )
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
	
	
	hook.Call("OnBanlistChanged" )
end )
