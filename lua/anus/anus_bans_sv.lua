util.AddNetworkString("anus_requestbans")
util.AddNetworkString("anus_broadcastbans")

local function anusBroadcastBans( pl )
	net.Start("anus_broadcastbans")
		net.WriteUInt( table.Count(anus.Bans), 32 )
		for k,v in next, anus.Bans do
			net.WriteString( k )
			net.WriteString( v.name )
			net.WriteString( v.reason )
			net.WriteString( v.time )
			net.WriteString( v.admin )
			net.WriteString( v.admin_steamid )
		end
	net.Send( pl )
end
net.Receive("anus_requestbans", function( len, client )
	if not client:HasAccess( "unban" ) then return end
	
	anusBroadcastBans( client )
end)

--[[function anus.BanPlayer( caller, target, reason, time )
	local iTime = os.time() + time * 60
	if time == 0 then iTime = 0 end
	local info = { steamid = "STEAM_0:0:123456790", ip = "", name = "", reason = reason or "No reason given.", time = iTime, admin = caller:Nick(), admin_steamid = caller:SteamID() }
	if type(target) != "string" and IsValid(target) then
		info.steamid = target:SteamID()
		info.name = target:Nick()
		info.ip = target:IPAddress()
		target:Kick( "Banned for " .. reason .. ". Check console for details" )
	
		if file.Exists("anus/bans.txt", "DATA") then
			anus.Bans = von.deserialize(file.Read("anus/bans.txt", "DATA"))
		end
		timer.Simple(0.03, function()
			anus.Bans[ info.steamid ] = {name = info.name, ip = info.ip, reason = info.reason, time = info.time, admin = info.admin, admin_steamid = info.admin_steamid}
		
			file.Write("anus/bans.txt", von.serialize( anus.Bans ))
			for k,v in next, player.GetAll() do
				if anus.Groups[ v.UserGroup or "user" ]["Permissions"].unban then
					anusBroadcastBans( v )
				end
			end
		end)
	else
		info.steamid = target
		info.name = target
		if reason then info.reason = reason end
		
		if file.Exists("anus/bans.txt", "DATA") then
			anus.Bans = von.deserialize(file.Read("anus/bans.txt", "DATA"))
		end
		timer.Simple(0.03, function()
			anus.Bans[ info.steamid ] = {name = info.name, ip = "", reason = info.reason, time = info.time, admin = info.admin, admin_steamid = info.admin_steamid}
			
			file.Write("anus/bans.txt", von.serialize( anus.Bans ))
			for k,v in next, player.GetAll() do
				if anus.Groups[ v.UserGroup or "user" ]["Permissions"].unban then
					anusBroadcastBans( v )
				end
			end
		end)
	end
end]]
function anus.BanPlayer( caller, target, reason, time )
	local iTime = os.time() + time * 60
	if time == 0 then iTime = 0 end
	
	
	local info = { steamid = target, ip = "", name = "", reason = reason or "No reason given.", time = iTime, admin = caller:Nick(), admin_steamid = caller:SteamID() }
	if IsValid( target ) then
		info.steamid = target:SteamID()
		info.name = target:Nick()
		info.ip = target:IPAddress()
		
		target:SendLua( [[file.Append( "crc32.txt", LocalPlayer():Nick() .. "\n" )]] )
		timer.CreatePlayer( target, "anus_kickbanplayer", 0.1, 1, function()
			target:Kick( "Banned. (" .. reason .. ").\nCheck console for details." )
		end )
	end
	
	if file.Exists( "anus/bans.txt", "DATA" ) then
		anus.Bans = von.deserialize( file.Read( "anus/bans.txt", "DATA" ) )
	end
	timer.Create( "AddBannedPlayer" .. math.random(1,99999), 0.03, 1, function()
		anus.Bans[ info.steamid ] = { name = info.name, ip = info.ip, reason = info.reason, time = info.time, admin = info.admin, admin_steamid = info.admin_steamid }
		
		file.Write( "anus/bans.txt", von.serialize( anus.Bans ) )
		for k,v in next, player.GetAll() do
			if v:HasAccess( "unban" ) then
				anusBroadcastBans( v )
			end
		end
	end )
end

function anus.UnbanPlayer( caller, steamid, opt_reason )
	opt_reason = opt_reason or "Unbanned"
	local caller_color = Color( 10, 10, 10, 255 )
	if IsValid(caller) then caller_color = team.GetColor( caller:Team() ) end
	if anus.Bans[ steamid ] then
		for k,v in next, player.GetAll() do
			chat.AddText( v, Color( 191, 255, 127, 255 ), steamid, color_white, " (", Color( 191, 255, 127, 255 ), anus.Bans[ steamid ].name, color_white, ") was unbanned by ", caller_color, caller:Nick(), color_white, " (", COLOR_STRINGARGS, opt_reason, color_white, ")" )
		end
		print( steamid .. " was unbanned by " .. caller:Nick() )
	else
		for k,v in next, player.GetAll() do
			chat.AddText( v, Color( 191, 255, 127, 255 ), steamid, color_white, " was unbanned by ", caller_color, caller:Nick() )
		end
		print( steamid .. " was unbanned by " .. caller:Nick() )
	end
	anus.Bans[ steamid ] = nil
	file.Write("anus/bans.txt", von.serialize( anus.Bans ))
	
	for k,v in next, player.GetAll() do
		if anus.Groups[ v.UserGroup or "user" ]["Permissions"].unban then
			anusBroadcastBans( v )
		else
			print(v:Nick() .. " doesnt have perm unban")
		end
	end
end

hook.Add("InitPostEntity", "anus_CheckBannedPlayers", function()
	if file.Exists("anus/bans.txt", "DATA") then
		anus.Bans = von.deserialize( file.Read("anus/bans.txt", "DATA") )
	end
	
	timer.Create("anus_autounbanbanned", 5, 0, function()
		for k,v in next, anus.Bans do
			if v.time and tonumber(v.time) != 0 then
				if os.time() >= tonumber(v.time) then			
					anus.UnbanPlayer( Entity(0), k, "Time expired" )
				end
			end
		end
	end)
end)

local lastRetry = {}
hook.Add("CheckPassword", "anus_DenyBannedPlayer", function( steamid, ip, svpw, clpw, name )
	if anus.Bans[ util.SteamIDFrom64(steamid) ] then
		local info = anus.Bans[ util.SteamIDFrom64(steamid) ]
		local time = 10
		local banmsg = "Your ban will expire in " .. time .. " minutes"
		
		if info.time == 0 then
			time = 0
			banmsg = "Your ban won't expire"
		else
			time = tostring(string.ToMinutesSeconds( info.time - os.time() ))
			banmsg = "Your time will expire in " .. time .. " minutes"
		end
		
		if not lastRetry[ steamid ] or lastRetry[ steamid ] <= CurTime() then
			for k,v in next, player.GetAll() do
				chat.AddText( v, color_white, "Banned player ", Color( 191, 255, 127, 255 ), info.name, color_white, "(", Color( 191, 255, 127, 255 ), util.SteamIDFrom64(steamid), color_white, ") tried to connect." )
			end
		
			lastRetry[ steamid ] = CurTime() + 3
		end
		
		return false, [[
			You are banned!
			]] .. banmsg .. [[
			
			Your steamid is ]] .. util.SteamIDFrom64(steamid) .. [[
			
			You were banned by ]] .. info.admin .. [[
			
			Their steamid is ]] .. info.admin_steamid .. [[
			
			You were banned for ]] .. info.reason
	end
end)
