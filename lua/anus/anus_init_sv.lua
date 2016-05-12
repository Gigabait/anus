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

function anusBroadcastUsers( pl )
	net.Start("anus_broadcastusers")
		net.WriteUInt( table.Count(anus.Users), 8 )
		for k,v in next, anus.Users do
			net.WriteString( v.group )
			net.WriteString( k )
			if v.name then
				net.WriteString( v.name )
			else
				net.WriteString( k )
			end
			net.WriteString( v.time or "0" ) 
		end
	net.Send( pl )
end

net.Receive("anus_requestusers", function( len, pl )
	if not pl:HasAccess( "configuregroups" ) then return end
	
	anusBroadcastUsers( pl )
end)

local network =
{
[ "unban" ] = "Bans",
[ "pluginload" ] = "Plugins",
}
hook.Add( "anus_PlayerAuthenticated", "anus_networktables", function( pl )
	local count = 0
	for k,v in next, network do
		count = count + 1
		timer.CreatePlayer( pl, "networktables" .. k, 0.5 * count, 1, function()
			if pl:HasAccess( k ) then
				_G[ "anusBroadcast" .. v ]( pl )
			end
		end )
	end
	
	timer.CreatePlayer( pl, "networktablesgroupsusers", 0.35, 1, function()
		anusBroadcastGroups( pl )
		
		if pl:IsAnusSendable() then
			anusBroadcastUsers( pl )
			anusSendPlayerPerms( pl, nil, nil, true )
			for k,v in next, player.GetAll() do
				if v == pl then continue end

				timer.CreatePlayer( pl, "networktablesperms" .. v:UserID(), 0.3 * k, 1, function()
					anusSendPlayerPerms( v, nil, nil, false, pl )
				end )
			end
		end
	end )
	
	file.CreateDir( "anus/users/" .. anus.SafeSteamID( pl:SteamID() ) )
end )