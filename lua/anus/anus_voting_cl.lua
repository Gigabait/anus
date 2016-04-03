net.Receive( "anus_BroadcastVote", function()
	local args = {}

	local title = net.ReadString()
	local numargs = net.ReadUInt( 4 )
	for i=1,numargs do
		args[ i ] = net.ReadString()
	end
	local time = net.ReadUInt( 10 )
	
	createVote( title, args, time )
end )