util.AddNetworkString( "anus_BroadcastVote" )

function anus.StartVote( title, tblArgs, optTime, callback )
	anus.Votes = anus.Votes or {}
	
	if #anus.Votes > 0 then return false end
	if #tblArgs == 0 then return false end
	
	local time = type( optTime ) != "function" and optTime or 15
	local callback2 = callback or optTime
	
	anus.Votes[ 1 ] = { title = title, args = tblArgs, time = time, callback = callback2, voters = #player.GetAll(), votes = 0, answers = {} }
	
	timer.Create( "anus_VoteFinish", time, 1, function()
		anus.FinishVote()
	end )
	
	for k,v in next, player.GetAll() do
		v:ChatPrint( "Vote started: " .. title)
	end
	
	net.Start( "anus_BroadcastVote" )
		net.WriteString( title )
		net.WriteUInt( #tblArgs, 4 )
		for k,v in next, tblArgs do
			net.WriteString( v )
		end
		net.WriteUInt( time, 10 )
	net.Broadcast()
	
	return true 
end

function anus.FinishVote()
	for k,v in next, player.GetAll() do
		v.AnusVoted = false
	end
	
	if anus.Votes[ 1 ][ "callback" ] then
		anus.Votes[ 1 ][ "callback" ]( anus.Votes[ 1 ] )
	end
	anus.Votes = {}
end

function anus.HandleVoting( pl, cmd, arg )
	if not anus.Votes or not anus.Votes[ 1 ] then
		pl:ChatPrint( "There is no vote going on!" )
		return
	end
	
		-- let them change their vote?
	if pl.AnusVoted then
		pl:ChatPrint( "You have already voted!" )
		return
	end
	
	local answer = tonumber( arg[ 1 ] )
	if not answer or not anus.Votes[ 1 ][ "args" ][ answer ] then
		pl:ChatPrint( "Wrong argument supplied for vote." )
		return
	end

	anus.Votes[ 1 ][ "votes" ] = anus.Votes[ 1 ][ "votes" ] + 1
	anus.Votes[ 1 ][ "answers" ][ answer ] = (anus.Votes[ 1 ][ "answers" ][ answer ] or 0) + 1
	
	pl.AnusVoted = true
end
concommand.Add( "anus_castvote", anus.HandleVoting )