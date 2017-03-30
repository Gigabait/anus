function anus.teleportPlayer( from, to, bforce )
	local Pl = NULL
	if type( to ) == "Player" then
		pl = to
		to = to:GetPos()
	end

	if not util.IsInWorld( to ) and not bforce then return false end

	local Pos = {}
	local Tries = 10
	local Ang = 360

	for i = 1, Ang, Tries do
		local Rad = i * ( 3.14 / 180 )
		local X = 45 * math.cos( Rad )
		local Y = 45 * math.sin( Rad )

		Pos[ #Pos + 1 ] = to + Vector( X, Y, 0 )
	end

	if not IsValid( Pl ) then
		for k,v in ipairs( ents.GetAll() ) do
			if v:GetPos() == to then
				Pl = v
				break
			end
		end
	end

	local Tr = {}
	Tr.start = to
	Tr.endpos = Pos[ 1 ]
	Tr.filter = Pl

	local Tried = 1

	local Trace = util.TraceEntity( Tr, from )
	while Trace.Hit do
		Tried = Tried + 1
		if not Pos[ Tried ] then
			if bforce then
				return Pos[ 1 ]
			else
				return false
			end
		end

		Tr.endpos = Pos[ Tried ]
		Trace = util.TraceEntity( Tr, from )
	end

	return Pos[ Tried ]
end

function anus.serverLog( msg, isdebug, nocon )
	if not nocon then
		ServerLog( "[anus] " .. msg .. "\n" )
	end
	local Date = os.date( "%d_%m_%Y", os.time() )
	local Time = os.date( "%H:%M:%S", os.time() )
	local Path = not isdebug and "logs" or "debuglogs"
	file.Append( "anus/" .. Path .. "/" .. Date .. ".txt", Time .. " - " .. msg .. "\n" )
end

function anus.safeSteamID( steam )
	if isstring( steam ) then
		return steam:gsub( ":", "_" )
	else
		return steam:SteamID():gsub( ":", "_" )
	end
end

function timer.createPlayer( pl, identifier, delay, reps, callback )
	timer.Create( identifier .. "_" .. pl:UserID(), delay, reps, function()
			-- add to global table and remove them on disconnect instead.
		if not IsValid( pl ) then return end

		callback()
	end )
	pl.RemoveTimerDC = pl.RemoveTimerDC or {}
	pl.RemoveTimerDC[ identifier .. "_" .. pl:UserID() ] = true
end

function timer.destroyPlayer( pl, identifier )
	timer.Destroy( identifier .. "_" .. pl:UserID() )
	pl.RemoveTimerDC = pl.RemoveTimerDC or {}
	pl.RemoveTimerDC[ identifier .. "_" .. pl:UserID() ] = nil
end

hook.Add( "player_disconnect", "props_DestroyPlayerTimers", function( data )
	for k,v in next, Player( data.userid ).RemoveTimerDC or {} do
		timer.Remove( k )
	end
end )