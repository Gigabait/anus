include( "anus/menu/base/anus_votepanel.lua" )

net.Receive( "anus_BroadcastVote", function()
	local Args = {}

	local Title = net.ReadString()
	local NumArgs = net.ReadUInt( 4 )
	for i=1,NumArgs do
		Args[ i ] = net.ReadString()
	end
	local Time = net.ReadUInt( 10 )

	local function Callback( id )
		if id == 0 then id = 10 end
		if not Args[ id ] then return end

		RunConsoleCommand( "anus_castvote", id )
		endVote()

		return true
	end

	LocalPlayer():AddPlayerOption( Title, Time, Callback, createVote( Title, Args, Time ) )
end )