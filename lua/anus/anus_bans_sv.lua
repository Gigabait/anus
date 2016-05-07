util.AddNetworkString("anus_requestbans")
util.AddNetworkString("anus_broadcastbans")

	-- chunk after 500 of these bad boys
function anusBroadcastBans( pl )
	--[[local num = 500
	local numinc = 0
	net.Start("anus_broadcastbans")
		net.WriteUInt( num/*table.Count(anus.Bans)*/, 16 )
		for k,v in next, anus.Bans do
			--if numinc >= num then break end
			--numinc = numinc + 1
			net.WriteString( k )
			net.WriteString( v.name )
			net.WriteString( v.reason )
			net.WriteString( v.time )
			net.WriteString( v.admin )
			net.WriteString( v.admin_steamid )
		end
	net.Send( pl )]]
	
	local count = table.Count( anus.Bans )
	local bans = table.Copy( anus.Bans )
	local chunk = 500
	local sent = 0
	local whattosend = math.ceil( count / chunk )
	local timerCreate = timer.Create
	local netStart = net.Start
	local netWriteUInt = net.WriteUInt
	local netWriteString = net.WriteString
	local netSend = net.Send
		-- chunkables by 500 bans, at 1816 thats 4
	for i=1, whattosend do --math.ceil( count / chunk ) do
			-- create a small delay between each chunk sent
		timerCreate( "anus_broadcastbans_" .. pl:UserID() .. "_chunk_" .. i, 0.05 * i, 1, function()
			if not IsValid( pl ) then return end
	
			local numinc = 0
		
			netStart( "anus_broadcastbans" )
					-- tell client how many chunks we are sending
				netWriteUInt( whattosend, 8 )
					-- tell client which chunk we are on
				netWriteUInt( i, 8 )
					-- tell client how many times to loop through
				netWriteUInt( table.Count(bans) > chunk and chunk or table.Count(bans)/*table.Count( anus.Bans )*/, 18 )
				for k,v in next, bans do
					if numinc >= chunk then break end
					sent = sent + 1 
					numinc = numinc + 1

					netWriteString( k )
					netWriteString( v.name )
					netWriteString( v.reason )
					netWriteString( v.time )
					netWriteString( v.admin )
					netWriteString( v.admin_steamid )
					
					bans[ k ] = nil
				end
			netSend( pl )
		end )
	end
	--[[timer.Simple( 0.1 + (0.05 * math.ceil( count / chunk ) ), function()
		print( "sENT TOTLA BANS: " .. sent )
		print( "TOTAL BANS: " .. count )
	end )]]
				
end

net.Receive("anus_requestbans", function( len, pl )
	if not pl:HasAccess( "unban" ) then return end

	anusBroadcastBans( pl )
end)

function anus.SaveBans()
	file.Write( "anus/bans.txt", von.serialize( anus.Bans ) )
end

function anus.BanPlayer( caller, target, reason, time )
	caller = IsValid( caller ) and caller or Entity( 0 )

	local iTime = os.time() + time
	if time == 0 then iTime = 0 end

	if type( target ) == "string" then
		target = string.gsub( target, "\"", "" )
	end
	
	local info = { steamid = target, ip = "", name = target, reason = reason or "No reason given.", time = iTime, admin = caller:Nick(), admin_steamid = caller:SteamID() }
	if type( target ) != "string" and IsValid( target ) then
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
		
		anus.SaveBans()
		for k,v in next, player.GetAll() do
			if v:HasAccess( "unban" ) then
				anusBroadcastBans( v )
			end
		end
	end )
	
	if time and time != 0 then
		--print( "registering ban for " .. info.steamid .. " : time: " .. time )
		anus.BanExpiration[ info.steamid ] = os.time() + time
	elseif not time or time == 0 and anus.BanExpiration[ info.steamid ] then
		anus.BanExpiration[ info.steamid ] = nil
	end
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
	if anus.BanExpiration[ steamid ] then
		anus.BanExpiration[ steamid ] = nil
	end
	anus.SaveBans()
	
	for k,v in next, player.GetAll() do
		if anus.Groups[ v.UserGroup or "user" ]["Permissions"].unban then
			anusBroadcastBans( v )
		end
	end
end

hook.Add( "InitPostEntity", "anus_CheckBannedPlayers", function()
	if file.Exists( "anus/bans.txt", "DATA" ) then
		anus.Bans = von.deserialize( file.Read( "anus/bans.txt", "DATA" ) )
	end
	
	anus.BanExpiration = {}
	for k,v in next, anus.Bans do
		if v.time and tonumber( v.time ) != 0 then
			anus.BanExpiration[ k ] = v.time
		end
	end
	
	timer.Create( "anus_autounbanbanned", 3, 0, function()
		local ostime = os.time
		local tonumber = tonumber
		for k,v in next, anus.BanExpiration do
			v = tonumber( v )
			if v != 0 then
				if ostime() >= v then
					anus.UnbanPlayer( Entity(0), k, "Time expired" )
				end
			else
					-- their time was changed. remove them here.
				anus.BanExpiration[ k ] = nil
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
			anus.ServerLog( "Banned player " .. info.name .. " (" .. util.SteamIDFrom64( steamid ) .. " ) (" .. ip .. ") tried to connect.", true )
			for k,v in next, player.GetAll() do
				chat.AddText( v, color_white, "Banned player ", Color( 191, 255, 127, 255 ), info.name, color_white, " (", Color( 191, 255, 127, 255 ), util.SteamIDFrom64( steamid ), color_white, ") tried to connect." )
			end
		
			lastRetry[ steamid ] = CurTime() + 5
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


util.AddNetworkString( "anus_bans_editreason" )

net.Receive( "anus_bans_editreason", function( len, pl )
	if not pl:HasAccess( "unban" ) then return end

	local steamid = net.ReadString()
	local reason = net.ReadString()
	
	if not anus.Bans[ steamid ] then return end
	
	anus.Bans[ steamid ][ "reason" ] = reason
	anus.SaveBans()
	
	for k,v in next, player.GetAll() do
		if anus.Groups[ v.UserGroup or "user" ]["Permissions"].unban then
			anusBroadcastBans( v )
		end
	end
end )

util.AddNetworkString( "anus_bans_edittime" )

net.Receive( "anus_bans_edittime", function( len, pl )
	if not pl:HasAccess( "unban" ) then return end
	
	local steamid = net.ReadString()
	local time = net.ReadString()
	
	if not anus.Bans[ steamid ] then return end
	
	time = time
	if not tonumber( time ) then
		time = anus.ConvertStringToTime( time ) or anus.ConvertStringToTime( "1m" )
	elseif tonumber( time ) and time == "0" then
		time = anus.ConvertStringToTime( time )
	elseif tonumber( time ) then
		time = anus.ConvertStringToTime( time .. "m" )
	end
	
	
	--[[time = tonumber( time ) or anus.ConvertStringToTime( time )
	if not time then
		time = "1d"
	end]]
		
	anus.Bans[ steamid ][ "time" ] = time == 0 and 0 or os.time() + time
	anus.SaveBans()
	
	for k,v in next, player.GetAll() do
		if anus.Groups[ v.UserGroup or "user" ]["Permissions"].unban then
			anusBroadcastBans( v )
		end
	end
end )