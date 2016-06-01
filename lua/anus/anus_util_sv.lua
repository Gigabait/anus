	-- my own.
function anus.TeleportPlayer( from, to, bForce )
	local pl = NULL
	if type( to ) == "Player" then
		pl = to
		to = to:GetPos()
	end
	
	if not util.IsInWorld( to ) and not bForce then return false end
	
	local pos = {}
	local tries = 10
	local ang = 360
	
	for i=1,ang,tries do
		local rad = i * (3.14 / 180)
		local x = 45 * math.cos( rad )
		local y = 45 * math.sin( rad )
	
		pos[ #pos + 1 ] = to + Vector( x, y, 0 )
	end
	
	if not IsValid( pl ) then
		for k,v in next, ents.GetAll() do
			if v:GetPos() == to then
				pl = v
				break
			end
		end
	end
	
	local tr = {}
	tr.start = to
	tr.endpos = pos[ 1 ]
	tr.filter = pl
	
	local tried = 1
	
	local trace = util.TraceEntity( tr, from )
	while trace.Hit do
		tried = tried + 1 
		if not pos[ tried ] then
			if bForce then
				return pos[ 1 ]
			else
				return false
			end
		end
		
		tr.endpos = pos[ tried ]
		trace = util.TraceEntity( tr, from )
	end
	
	return pos[ tried ]
end

function anus.ServerLog( msg, isdebug )
	ServerLog( "[anus] " .. msg .. "\n" )
	local date = os.date( "%d_%m_%Y", os.time() )
	local time = os.date( "%H:%M:%S", os.time() )
	local path = not isdebug and "logs" or "debuglogs" 
	file.Append( "anus/" .. path .. "/" .. date .. ".txt", time .. " - " .. msg .. "\n" )
end

function anus.SafeSteamID( steam )
	if type( steam ) == "string" then
		return string.gsub( steam, ":", "_" )
	else
		return string.gsub( steam:SteamID(), ":", "_" )
	end
end

function timer.CreatePlayer( pl, identifier, delay, reps, callback )
	timer.Create( identifier .. "_" .. pl:UserID(), delay, reps, function()
			-- add to global table and remove them on disconnect instead.
		if not IsValid( pl ) then return end
		
		callback()
	end )
	pl.RemoveTimerDC = pl.RemoveTimerDC or {}
	pl.RemoveTimerDC[ identifier .. "_" .. pl:UserID() ] = true
end

hook.Add( "player_disconnect", "props_DestroyPlayerTimers", function( data )
	for k,v in next, Player( data.userid ).RemoveTimerDC or {} do
		timer.Destroy( k )
	end
end )

	-- meep
local _R = debug.getregistry()
if not OLD_ERROR then
	OLD_ERROR = _R[ 1 ]
	_R[ 1 ] = function( ... )
		pcall( hook.Call, "LuaError", gmod.GetGamemode(), ... )
		return OLD_ERROR( ... )
	end
end