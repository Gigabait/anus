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

--[[concommand.Add( "test", function( pl )
	local a = 1
	timer.Create( "testpos", 0.1, 360, function()
		local pos = anus.TeleportPlayer2( Entity(2), pl, false, a )
		if pos then 
			Entity(2):SetPos( pos ) 
		end
		a = a + 1
	end )
end )

concommand.Add( "test2", function( pl )
	for k,v in next, player.GetBots() do 
		local pos = anus.TeleportPlayer2( v, pl, false  )
		if pos then 
			v:SetPos( pos )
		end
	end
end )]]


function anus.ServerLog( msg, isdebug )
	ServerLog( "[anus] " .. msg .. "\n" )
	local date = os.date( "%d_%m_%Y", os.time() )
	local time = os.date( "%H:%M:%S", os.time() )
	local path = not isdebug and "logs" or "debuglogs" 
	file.Append( "anus/" .. path .. "/" .. date .. ".txt", time .. " - " .. msg .. "\n" )
end