local filename = anus.GetFileName(debug.getinfo(1, "S").short_src)

print([[------------------------------
------------------------------
	ANUS - ]] .. filename .. [[
	
------------------------------
------------------------------]])

util.AddNetworkString("anus_requestdc")
util.AddNetworkString("anus_broadcastdc")
util.AddNetworkString("anus_requestusers")
util.AddNetworkString("anus_broadcastusers")
anus.PlayerDC = anus.PlayerDC or {}

	-- include an offset with server time and client time
	-- if servertime > clienttime then offset = servertime - clienttime
	-- for k,v in pairs(anus.PlayerDC) do AddToList( v.time - clienttime ) end
hook.Add("PlayerDisconnected", "anus_CatchDisconects", function( pl )
		-- os.date("%H:%M:%S") --- clientside
	anus.PlayerDC[ pl:SteamID() ] = {name = pl:Nick(), kills = pl:Frags(), hour = os.date("%H"), minute = os.date("%M"), second = os.date("%S")}
end)

net.Receive("anus_requestdc", function( len, pl )
	if not pl:HasAccess( "unban" ) then return end

	net.Start("anus_broadcastdc")
		net.WriteUInt( table.Count(anus.PlayerDC), 12 )
			-- so the client can offset the time
		net.WriteUInt( os.date("%H"), 6 )
		for k,v in next, anus.PlayerDC do
			net.WriteString( k )
			net.WriteString( v.name )
			net.WriteUInt( v.kills, 16 )
			net.WriteUInt( v.hour, 6 )
			net.WriteUInt( v.minute, 8 )
			net.WriteUInt( v.second, 8 )
		end
	net.Send( pl )
end)

local function anusBroadcastUsers( pl )
	net.Start("anus_broadcastusers")
		net.WriteUInt( table.Count(anus.Users), 8 )
		for k,v in next, anus.Users do
			net.WriteString(v.group)
			net.WriteString( k )
			if v.name then
				net.WriteString( v.name )
			else
				net.WriteString( k )
			end
		end
	net.Send( pl )
end

net.Receive("anus_requestusers", function( len, pl )
	if not pl:HasAccess( "configuregroups" ) then return end
	
	anusBroadcastUsers( pl )
end)

	-- Thanks ULX. Will remove if requested.
function anus.TeleportPlayer( from, to, bForce )
	if not to:IsInWorld() and not bForce then return false end

	local yawForward = to:EyeAngles().yaw
	local directions = { -- Directions to try
		math.NormalizeAngle( yawForward - 180 ), -- Behind first
		math.NormalizeAngle( yawForward + 180 ), -- Front
		math.NormalizeAngle( yawForward + 90 ), -- Right
		math.NormalizeAngle( yawForward - 90 ), -- Left
		yawForward,
	}

	local t = {}
	t.start = to:GetPos() + Vector( 0, 0, 15 ) -- Move them up a bit so they can travel across the ground
	t.filter = { to, from }

	local i = 1
	t.endpos = to:GetPos() + Angle( 0, directions[ i ], 0 ):Forward() * 47 -- (33 is player width, this is sqrt( 33^2 * 2 ))
	local tr = util.TraceEntity( t, from )
	while tr.Hit do -- While it's hitting something, check other angles
		i = i + 1
		if i > #directions then  -- No place found
			if bForce then
				return to:GetPos() + Angle( 0, directions[ 1 ], 0 ):Forward() * 47
			else
				return false
			end
		end

		t.endpos = to:GetPos() + Angle( 0, directions[ i ], 0 ):Forward() * 47

		tr = util.TraceEntity( t, from )
	end

	return tr.HitPos
end

function anus.ServerLog( msg, isdebug )
	ServerLog( "[anus] " .. msg .. "\n" )
	local date = os.date( "%d_%m_%Y", os.time() )
	local time = os.date( "%H:%M:%S", os.time() )
	local path = not isdebug and "logs" or "debuglogs" 
	file.Append( "anus/" .. path .. "/" .. date .. ".txt", time .. " - " .. msg .. "\n" )
end