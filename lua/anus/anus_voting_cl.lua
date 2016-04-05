net.Receive( "anus_BroadcastVote", function()
	local args = {}

	local title = net.ReadString()
	local numargs = net.ReadUInt( 4 )
	for i=1,numargs do
		args[ i ] = net.ReadString()
	end
	local time = net.ReadUInt( 10 )
	
		-- shamelessly copied callback info from ulx
		-- didnt know what to do  .. .
	local function callback( id )
		if id == 0 then id = 10 end
		if not args[ id ] then return end
		
		RunConsoleCommand( "anus_castvote", id )
		endVote()
		
		return true
	end
	
	LocalPlayer():AddPlayerOption( title, time, callback, createVote( title, args, time ) )
	
	--createVote( title, args, time )
end )