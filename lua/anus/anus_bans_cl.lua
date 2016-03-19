net.Receive( "anus_broadcastbans", function()
	anus.Bans = {}

	print( "banns broadcasted :)" )
	
	local amt = net.ReadUInt( 32 )
	for i=1,amt do
		anus.Bans[ net.ReadString() ] = { name = net.ReadString(), reason = net.ReadString(), time = net.ReadString(), admin = net.ReadString(), admin_steamid = net.ReadString() }
	end
	
	hook.Call("OnBanlistChanged" )
end )
