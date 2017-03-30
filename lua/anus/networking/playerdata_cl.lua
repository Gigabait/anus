--[[
		Player Time Offset
	
	Desc: Allows the client to see times relative to themselves rather than just the server.
]]--

if not anus.serverOffset then
	anus.serverOffset = 0
end

net.Receive( "anus_time_networkoffset", function()
	local ServerTime = net.ReadUInt( 32 )
	
	anus.serverOffset = os.time() - ServerTime
end )

net.Receive( "anus_ban_networkbans", function( len )
	local BanType = net.ReadUInt( 2 )

	if BanType == 0 then
		local Chunk = net.ReadUInt( 8 )
		local Amt = net.ReadUInt( 18 )

		if Chunk == 1 then
			anus.Bans = {}
		end

		for i=1,Amt do
			local SteamId = net.ReadString()

			anus.Bans[ SteamId ] = { name = net.ReadString(), reason = net.ReadString(), unbandate = net.ReadString(), admin = net.ReadString(), admin_steamid = net.ReadString() }
			if net.ReadBool() then
				anus.Bans[ SteamId ].reason_old = net.ReadString()
				anus.Bans[ SteamId ].admin_steamid_modified = net.ReadString()
			end
		end

		hook.Call( "OnBanlistChanged" )
	elseif BanType == 1 then
		local SteamId = net.ReadString()
		
		anus.Bans[ SteamId ] = { name = net.ReadString(), reason = net.ReadString(), unbandate = net.ReadString(), admin = net.ReadString(), admin_steamid = net.ReadString() }
		if net.ReadBool() then
			anus.Bans[ SteamId ].reason_old = net.ReadString()
			anus.Bans[ SteamId ].admin_steamid_modified = net.ReadString()
		end
		
		hook.Call( "OnBanlistChanged", nil, BanType, SteamId )
	elseif BanType == 2 then
		local SteamId = net.ReadString()

		anus.Bans[ SteamId ] = nil

		hook.Call( "OnBanlistChanged", nil, BanType, SteamId )
	end
end )




net.Receive( "anus_group_networkgroups", function()
	anus.Groups = net.ReadTable()
end )

net.Receive( "anus_group_networkplayergroup", function()
--local function anus_Group_NetworkPlayerGroup( len, target, group, time, name, promoted )
	local Target = target or ( net.ReadUInt( 7 ) + 1 )
	local Group = group or net.ReadString()
	local Time = time or net.ReadString()
	local Name = name or net.ReadString()
	local Promoted = promoted or net.ReadString()

	anus.Users, anus.tempUsers = anus.Users or {}, anus.tempUsers or {}
	anus.Users[ Group ] = anus.Users[ Group ] or {}
	
	local function InitUser( target, retries )
		local Target = Entity( target )
		
		if not IsValid( Target ) then
			if retries > 5 then return end
		
			timer.Create( "anus_RetryInitUser_" .. target .. "_" .. CurTime(), 0.75, 1, function()
				InitUser( target, retries + 1 )
			end )
		else
			if Time != "none" then
				anus.Users[ Group ][ Target:SteamID() ] = { name = Name, time = Time, promoted_time = Promoted }
				if Time != "0" then
					anus.tempUsers[ Target:SteamID() ] = { name = Name, group = Group, time = Time, promoted_time = Promoted }
				end
			else
				anus.Users[ Group ][ Target:SteamID() ] = nil
			end
				
			steamworks.RequestPlayerInfo( util.SteamIDTo64( Target:SteamID() ) )

			for k,v in next, anus.Users do
				if k == Group then continue end

				for a,b in next, v do
					if a == Target:SteamID() then
						anus.Users[ k ][ a ] = nil
					end
				end
			end
			
			if Target == LocalPlayer() then
				timer.Simple( 0.1, function() hook.Call( "anus_LocalPlayerDataChanged", nil ) end )
				return
			end
			
			timer.Simple( 0.1, function() hook.Call( "anus_PlayerDataChanged", nil, Target:SteamID(), Group ) end )
		end
	end
	InitUser( Target, 0 )
end )

net.Receive( "anus_group_networksteamgroup", function()
	local SteamID = net.ReadString()
	local Group = net.ReadString()
	local Time = net.ReadString()
	local Name = net.ReadString()
	local Promoted = net.ReadString()
	
	anus.Users, anus.tempUsers = anus.Users or {}, anus.tempUsers or {}
	anus.Users[ Group ] = anus.Users[ Group ] or {}
	
	if Time != "none" then
		anus.Users[ Group ][ SteamID ] = { name = Name, time = Time, promoted_time = Promoted }
		if Time != "0" then
			anus.tempUsers[ SteamID ] = { name = Name, group = Group, time = Time, promoted_time = Promoted }
		end
	else
		anus.Users[ Group ][ SteamID ] = nil
	end
		
	steamworks.RequestPlayerInfo( util.SteamIDTo64( SteamID ) )

	for k,v in next, anus.Users do
		if k == Group then continue end

		for a,b in next, v do
			if a == SteamID then
				--print( k, a )
				anus.Users[ k ][ a ] = nil
			end
		end
	end
	
	hook.Call( "anus_PlayerDataChanged", nil, SteamID, Group )
end )
	
net.Receive( "anus_group_networkplayerperms", function()
	anus.clientsidePlayerData = anus.clientsidePlayerData or {}
	
	local Target = net.ReadUInt( 7 ) + 1
	local Group = net.ReadString()
	local IsAdmin = net.ReadBool()
	local IsSuperAdmin = net.ReadBool()
	local Perms = net.ReadTable()
	
	local function InitPlayerData( target, retries )
		local Target = Entity( target )

		if not IsValid( Target ) then
			if retries > 5 then return end
			
			timer.Create( "anus_RetryPlayerData_" .. target .. "_" .. CurTime(), 0.75, 1, function()
				InitPlayerData( target, retries + 1 )
			end )
		else
			anus.clientsidePlayerData[ Target ] = { group = Group, admin = IsAdmin, superadmin = IsSuperAdmin, perms = Perms, steamid = Target:SteamID() }
			
			if Target == LocalPlayer() then
				for k,v in next, Perms do
					if not anus.getPlugins()[ k ] then continue end
					
					anus.addCommand( anus.getPlugins()[ k ] )
				end
				
				hook.Call( "anus_LocalPlayerDataChanged", nil, Perms )
			end
		end
	end
	InitPlayerData( Target, 0 )
end )
net.Receive( "anus_group_networksteamperms", function ()
	anus.clientsidePlayerData = anus.clientsidePlayerData or {}
	
	local SteamID = net.ReadString()
	local Group = net.ReadString()
	local IsAdmin = net.ReadBool()
	local IsSuperAdmin = net.ReadBool()
	local Perms = net.ReadTable()
	
	anus.clientsidePlayerData[ SteamID ] = { notplayer = true, group = Group, admin = IsAdmin, superadmin = IsSuperAdmin, perms = Perms, steamid = SteamID }
end )
hook.Add( "player_disconnect", "anusResetNetworkedPlayerData", function( data )
	local Target = Player( data.userid )

	if anus.clientsidePlayerData and anus.clientsidePlayerData[ Target ] then
		anus.clientsidePlayerData[ Target ] = nil
	end
end )
	-- The above won't work if we kick multiple (>~12) 
timer.Create( "anusResetNetworkedPlayerData", 300, 0, function()
	for k,v in next, anus.clientsidePlayerData or {} do
		if not IsValid( k ) then
			anus.clientsidePlayerData[ k ] = nil
		end
	end
end )

net.Receive( "anus_group_resetplayerperms", function()
	anus.clientsidePlayerData = {}
end )


net.Receive( "anus_plugins_networkplugins", function()
	anus.unloadedPlugins = anus.unloadedPlugins or {}

	local Count = net.ReadUInt( 8 )
	for i=1,Count do
		local Plugin = net.ReadString()
		
		anus.unloadedPlugins[ Plugin ] = true --net.ReadBool()
		if anus.getPlugins()[ Plugin ] then
			anus.getPlugins()[ Plugin ].disabled = true
		end
	end
end )








local aids = true
if aids then return end



hook.Add( "Initialize", "anus_InitialzeClientTables", function()
	LocalPlayer().PlayerInfo = {}
end )

net.Receive( "anus_playerperms", function()
	LocalPlayer().PlayerInfo = LocalPlayer().PlayerInfo or {}

	local Pl = net.ReadEntity()
	local Group = net.ReadString()
	local Time = net.ReadUInt( 18 )
	local Admin = net.ReadBit()
	local SAdmin = net.ReadBit()


	LocalPlayer().PlayerInfo[ Pl ] = { group = Group, time = Time, admin = Admin, superadmin = SAdmin, perms = {} }

	local Amt = net.ReadUInt( 10 )
	for i=1,Amt do
		LocalPlayer().PlayerInfo[ Pl ].perms[ net.ReadString() ] = net.ReadBit() == 1 and true or false
	end
	--LocalPlayer().PlayerInfo[ pl ].perms = net.ReadTable()

	if Pl == LocalPlayer() and Time != 0 then
		timer.Create( "anus_refreshtemp", 60, Time, function()
			LocalPlayer().PlayerInfo[ Pl ][ "expiretime" ] = LocalPlayer().PlayerInfo[ Pl ][ "expiretime" ] - 1
		end )
	end

	if Pl == LocalPlayer() then
		for k,v in next, LocalPlayer().PlayerInfo[ LocalPlayer() ].perms or {} do
			if not anus.getPlugins()[ k ] then continue end

			anus.addCommand( anus.getPlugins()[ k ] )
		end
	end

	--[[for k,v in next, LocalPlayer().PlayerInfo do
		if not IsValid( k ) then
			LocalPlayer().PlayerInfo[ k ] = nil
		end
	end]]
end )
hook.Add( "player_disconnect", "anusResetPlayerInfo", function( data )
	local Pl = Player( data.userid )

	if LocalPlayer().PlayerInfo and LocalPlayer().PlayerInfo[ Pl ] then
		LocalPlayer().PlayerInfo[ Pl ] = nil
	end
end )

net.Receive( "anus_clearplayerperms", function()
	LocalPlayer().PlayerInfo = {}
end )

anus.Users = anus.Users or {}
net.Receive( "anus_broadcastusers", function()
	anus.Users = {}
	anus.tempUsers = {}

	local amt = net.ReadUInt( 10 )
	for i=1,amt do
		local group = net.ReadString()
		local steamid = net.ReadString()
		local name = net.ReadString()
		local time = net.ReadString()
		anus.Users[ group ] = anus.Users[ group ] or {}
		anus.Users[ group ][ steamid ] = { name = name, time = time }
		if time != "0" then
			anus.tempUsers[ steamid ] = { group = group, name = name, time = time }
		end

		steamworks.RequestPlayerInfo( util.SteamIDTo64( steamid ) )

		for k,v in next, anus.Users do
			if k == group then continue end

			for a,b in next, v do
				if a == steamid then
					anus.Users[ a ] = nil
				end
			end
		end
	end

	hook.Call( "OnPlayerGroupsChanged" )
end )

net.Receive( "anus_networkusergroup", function()
	anus.Users = anus.Users or {}
	anus.tempUsers = anus.tempUsers or {}

	local group = net.ReadString()
	local steamid = net.ReadString()
	local name = net.ReadString()
	local time = net.ReadString()
	anus.Users[ group ] = anus.Users[ group ] or {}
	anus.Users[ group ][ steamid ] = { name = name, time = time }
	if time != "0" then
		anus.tempUsers[ steamid ] = { group = group, name = name, time = time }
	end

	steamworks.RequestPlayerInfo( util.SteamIDTo64( steamid ) )

	for k,v in next, anus.Users do
		if k == group then continue end

		for a,b in next, v do
			if a == steamid then
				anus.Users[ k ][ a ] = nil
			end
		end
	end
end )

--[[
		Queue System
		
	Desc: Networked items will be put in a queue to be loaded as soon as the client is valid
]]--
anus.clientsideNetworkQueue = anus.clientsideNetworkQueue or {}
function anus.clientsideProcessQueue()
end

function anus.clientsideAddNetworkQueue( callback, ... )
end