AddCSLuaFile( "anus/menu/base/anus_votepanel.lua" )

-- todo: add a delay for person that started last vote
-- when vote ends: add delay for client that started vote for 30 seconds before they can start another

util.AddNetworkString( "anus_BroadcastVote" )

function anus.startVote( title, tblargs, opttime, callback, caller )
	anus.Votes = anus.Votes or {}

	local Time = isfunction( callback ) and opttime or 15
	local Callback2 = callback or opttime

	if caller then
		local CanVote, Reason = hook.Call( "anus_PlayerCanStartVote", nil, caller, title, tblargs, Time )
		if not CanVote and CanVote != nil then return false, Reason or "Cannot start vote" end
	end
		-- temp to attempt to fix string arguments in regular commands
		-- this is my playground.
	if #anus.Votes > 0 then return false, "There is already a vote in progress!" end
	if #tblargs == 0 then return false, "Please supply some options" end

	anus.Votes[ 1 ] = { title = title, args = tblargs, time = Time, callback = Callback2, voters = #player.GetAll(), votes = 0, answers = {} }

	timer.Create( "anus_VoteFinish", Time, 1, function()
		anus.FinishVote()
	end )

	for k,v in ipairs( player.GetAll() ) do
		v:ChatPrint( "Vote started: " .. title )
	end

	net.Start( "anus_BroadcastVote" )
		net.WriteString( title )
		net.WriteUInt( #tblargs, 4 )
		for k,v in ipairs( tblargs ) do
			net.WriteString( v )
		end
		net.WriteUInt( Time, 10 )
	net.Broadcast()

	return true
end

function anus.FinishVote()
	for k,v in ipairs( player.GetAll() ) do
		v.AnusVoted = false
	end

	if anus.Votes[ 1 ][ "callback" ] then
		anus.Votes[ 1 ][ "callback" ]( anus.Votes[ 1 ] )
	end
	anus.Votes = {}
end

function anus.CancelVote()
	for k,v in ipairs( player.GetAll() ) do
		v.AnusVoted = false
	end

	local Vote = table.Copy( anus.Votes[ 1 ] )
	anus.Votes = {}

	return Vote.title
end

function anus.VoteExists()
	return anus.Votes and anus.Votes[ 1 ]
end

function anus.handleVoting( pl, cmd, arg )
	if not anus.Votes or not anus.Votes[ 1 ] then
		pl:ChatPrint( "There is no vote going on!" )
		return
	end

		-- let them change their vote?
	if pl.AnusVoted then
		pl:ChatPrint( "You have already voted!" )
		return
	end

	local Answer = tonumber( arg[ 1 ] )
	if not Answer or not anus.Votes[ 1 ][ "args" ][ Answer ] then
		pl:ChatPrint( "Wrong argument supplied for vote." )
		return
	end

	anus.Votes[ 1 ][ "votes" ] = anus.Votes[ 1 ][ "votes" ] + 1
	anus.Votes[ 1 ][ "answers" ][ Answer ] = (anus.Votes[ 1 ][ "answers" ][ Answer ] or 0) + 1
	
	pl.AnusVoted = true
end
concommand.Add( "anus_castvote", anus.handleVoting )