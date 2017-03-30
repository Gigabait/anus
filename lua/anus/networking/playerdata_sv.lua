	-- another day

util.AddNetworkString( "anus_time_networkoffset" )
util.AddNetworkString( "anus_group_networkgroups" )
util.AddNetworkString( "anus_group_networkplayergroup" )
util.AddNetworkString( "anus_group_networksteamgroup" )
util.AddNetworkString( "anus_group_networkplayerperms" )
util.AddNetworkString( "anus_group_networksteamperms" )
util.AddNetworkString( "anus_group_resetplayerperms" )
util.AddNetworkString( "anus_ban_requestbans" )
util.AddNetworkString( "anus_ban_networkbans" )
util.AddNetworkString( "anus_plugins_networkplugins" )

	-- chunk after 500 of these bad boys
function anusNetworkBans( pl, bindividual, steamid )
	if not bindividual then
		local Count = table.Count( anus.Bans )
		local Bans = table.Copy( anus.Bans )
		local Chunk = 500
		local Sent = 0
		local WhatToSend = math.ceil( Count / Chunk )
			-- chunkables by 500 bans, at 1816 thats 4
		for i=1, WhatToSend do
				-- create a small delay between each chunk sent
			timer.Create( "anus_networkbans_" .. pl:UserID() .. "_chunk_" .. i, 0.05 * i, 1, function()
				if not IsValid( pl ) then return end

				local NumInc = 0

				net.Start( "anus_ban_networkbans" )
					net.WriteUInt( 0, 2 )
						-- tell client which chunk we are on
					net.WriteUInt( i, 8 )
						-- tell client how many times to loop through
					net.WriteUInt( table.Count( Bans ) > Chunk and Chunk or table.Count( Bans ), 18 )
					for k,v in next, Bans do
						if NumInc >= Chunk then break end
						Sent = Sent + 1
						NumInc = NumInc + 1
						if not v.unbandate then
							anus.Bans[ k ].unbandate = 0
							Bans[ k ].unbandate = 0
						end

						net.WriteString( k )
						net.WriteString( v.name )
						net.WriteString( v.reason )
						net.WriteString( v.unbandate )
						net.WriteString( v.admin )
						net.WriteString( v.admin_steamid )
						net.WriteBool( v.admin_steamid_modified != nil )
						if v.admin_steamid_modified then
							net.WriteString( v.reason_old )
							net.WriteString( v.admin_steamid_modified )
						end
							
						Bans[ k ] = nil
					end
				net.Send( pl )
			end )
		end

		pl.anusNetworkedBans = true
	else
		local Bans = anus.Bans[ steamid ]
		net.Start( "anus_ban_networkbans" )
			net.WriteUInt( 1, 2 )
			net.WriteString( steamid )
			net.WriteString( Bans.name )
			net.WriteString( Bans.reason )
			net.WriteString( Bans.unbandate )
			net.WriteString( Bans.admin )
			net.WriteString( Bans.admin_steamid )
			net.WriteBool( Bans.admin_steamid_modified != nil )
			if Bans.admin_steamid_modified then
				net.WriteString( Bans.reason_old )
				net.WriteString( Bans.admin_steamid_modified )
			end
		net.Send( pl )
	end
end
function anusNetworkUnban( pl, steamid )
	net.Start( "anus_ban_networkbans" )
		net.WriteUInt( 2, 2 )
		net.WriteString( steamid )
	net.Send( pl )
end

net.Receive( "anus_ban_requestbans", function( len, pl )
	if not pl:hasAccess( "unban" ) then return end

	anusNetworkBans( pl )
end )

function anusNetworkPlugins( pl )
	--[[local Output = {}
	for k,v in next, anus.unloadedPlugins or {} do
		Output[ k ] = 0
	end]]

	local Output = anus.unloadedPlugins or {}
	net.Start( "anus_plugins_networkplugins" )
		net.WriteUInt( table.Count( Output ), 8 )
		for k,v in next, Output do
			net.WriteString( k )
			--net.WriteBool( v == 1 )
		end
	net.Send( pl )
end

	-- Replace Player.Perms with Player.anusPerms

function anusNetworkGroups( pl )
	net.Start( "anus_group_networkgroups" )
		net.WriteTable( anus.Groups )
	net.Send( pl )
end

function anusNetworkPlayerGroup( receiver, target, forceuser )
	local SteamID = target:SteamID()
	
	if not anus.Users[ SteamID ] or forceuser then
		net.Start( "anus_group_networkplayergroup" )
			net.WriteUInt( target:EntIndex() - 1, 7 )
			net.WriteString( "user" )
			net.WriteString( "none" )
		net.Send( receiver )
	
		return
	end
	
	local UserInfo = anus.Users[ SteamID ]
	
	net.Start( "anus_group_networkplayergroup" )
		net.WriteUInt( target:EntIndex() - 1, 7 )
		net.WriteString( UserInfo.group )
		net.WriteString( UserInfo.expiretime or "0" )
		net.WriteString( UserInfo.name or SteamID )
		net.WriteString( UserInfo.promoted_time or "0" )
	net.Send( receiver )
end

function anusBroadcastUsers( receiver )
	for k,v in ipairs( player.GetAll() ) do
		anusNetworkPlayerGroup( receiver, v )
	end
end

function anusNetworkSteamGroup( receiver, steamid, forceuser )
	if not anus.Users[ steamid ] or forceuser then
		net.Start( "anus_group_networksteamgroup" )
			net.WriteString( steamid )
			net.WriteString( "user" )
			net.WriteString( "none" )
		net.Send( receiver )
	
		return
	end
	
	local UserInfo = anus.Users[ steamid ]
	
	net.Start( "anus_group_networksteamgroup" )
		net.WriteString( steamid )
		net.WriteString( UserInfo.group )
		net.WriteString( UserInfo.expiretime or "0" )
		net.WriteString( UserInfo.name or steamid )
		net.WriteString( UserInfo.promoted_time or "0" )
	net.Send( receiver )
end

function anusNetworkPlayerPerms( receiver, target, sendtotarget )
	local Networkable = {}
	--[[local GroupPerms = anus.Groups[ target:GetUserGroup() ].Permissions or {}

	for k,v in next, target.Perms or {} do
		if v and not GroupPerms[ k ] then
			Networkable[ k ] = true
		elseif not v and v != nil and GroupPerms[ k ] then
			Networkable[ k ] = false
		end
	end]]
	
	if not target.anusPerms then
		timer.createPlayer( receiver, "anus_resent_networkplayerperms", 1, 1, function()
			if not IsValid( receiver ) or not IsValid( target ) then return end
			anusNetworkPlayerPerms( receiver, target )
		end )
	else
		net.Start( "anus_group_networkplayerperms" )
			net.WriteUInt( target:EntIndex() - 1, 7 )
			net.WriteString( target:GetUserGroup() )
			net.WriteBool( anus.Groups[ target:GetUserGroup() ].isadmin )
			net.WriteBool( anus.Groups[ target:GetUserGroup() ].issuperadmin )
			--[[net.WriteUInt( table.Count( Networkable ), 8 )
			for k,v in next, Networkable do
				net.WriteString( k )
				net.WriteBool( v )
			end]]
			net.WriteTable( target.anusPerms )
		net.Send( receiver )
	end
end

function anusNetworkSteamPerms( receiver, steamid )
	if not anus.Users[ steamid ] or not anus.Users[ steamid ].perms then return end
	
	local User = anus.Users[ steamid ]
	
	net.Start( "anus_group_networksteamperms" )
		net.WriteString( steamid )
		net.WriteString( User.group )
		net.WriteBool( anus.Groups[ User.group ].isadmin )
		net.WriteBool( anus.Groups[ User.group ].issuperadmin )
		net.WriteTable( User.perms )
	net.Send( receiver )
end

function anusResetPlayerPerms( target )
	net.Start( "anus_group_resetplayerperms" )
	net.Send( target )
end

net.Receive( "anus_requestgroups" , function( len, pl )
	if not pl:hasAccess( "addgroup" ) or not pl:hasAccess( "removegroup" ) then return end

	anusNetworkGroups( pl )
end )

function anusInternalNetworkPlayerData( pl )
	local UsersDelayCount = 0
	local UsersDelayTotal = 0
	local UsersDelayInterval = 0.03
	if pl:isAnusSendable() then
		for k,v in next, anus.Users do
			UsersDelayCount = UsersDelayCount + 1
			UsersDelayTotal = UsersDelayTotal + UsersDelayInterval

			timer.createPlayer( pl, "networkusers" .. k, UsersDelayInterval, 1, function()
				local FindPlayerBySteamID = anus.findPlayer( k, "steam" )
				if istable( FindPlayerBySteamID ) then
					for k,v in ipairs( FindPlayerBySteamID ) do
						anusNetworkPlayerGroup( pl, v )
						anusNetworkPlayerPerms( pl, v )
					end
				elseif FindPlayerBySteamID then
					anusNetworkPlayerGroup( pl, FindPlayerBySteamID )
					anusNetworkPlayerPerms( pl, FindPlayerBySteamID )
				else
					anusNetworkSteamGroup( pl, k )
				end
			end )
		end
	else
		anusResetPlayerPerms( pl )
		for k,v in next, anus.Users do
			anusNetworkSteamGroup( pl, k, true )
		end
	end
	
	return UsersDelayTotal
end

local function anus_OnAuthenticated( pl )
	pl.hasAuthenticated = true
	if game.SinglePlayer() or pl:IsListenServerHost() then
		pl:SetUserGroup( "owner" )
	else
		if anus.Users and anus.Users[ pl:SteamID() ] then
			if anus.Users[ pl:SteamID() ].expiretime then
					-- base_sv.lua takes care of the rest
				if os.time() <= anus.Users[ pl:SteamID() ].expiretime then
					pl:SetUserGroup( anus.Users[ pl:SteamID() ].group )
				end
			else
				pl:SetUserGroup( anus.Users[ pl:SteamID() ].group, true )
			end
		else
			pl:SetUserGroup( "user" )
		end
	end

	pl:SetNWString( "UserGroup", "user" )

	pl:assignID()
end

hook.Add( "PlayerInitialSpawn", "anus_authenticateplayer", function( pl )
	file.CreateDir( "anus/users/" .. anus.safeSteamID( pl:SteamID() ) )

			-- lets try a shorter time
	timer.createPlayer( pl, "anus_authenticateplayer", 0.03/*1.2*/, 1, function()
		anus_OnAuthenticated( pl )
	end )
end )

hook.Add( "PlayerSpawn", "anus_authenticateplayerpart_networking", function( pl )
	if not pl.hasAuthenticatedNetworked then
		hook.Call( "anus_PlayerAuthenticated", nil, pl )
		pl.hasAuthenticatedNetworked = true
	end
end )

hook.Add( "anus_PlayerAuthenticated", "anus_networktables", function( pl )
	anusNetworkGroups( pl )

	local DelayedTime = anusInternalNetworkPlayerData( pl )

	timer.createPlayer( pl, "networkplugins", DelayedTime, 1, function()
		anusNetworkPlugins( pl )
	end )

	timer.createPlayer( pl, "networkbans", DelayedTime + 1, 1, function()
		if pl:hasAccess( "unban" ) then
			anusNetworkBans( pl )
		end
	end )

	pl.anusPerms = {}

	if file.Exists( "anus/users/" .. anus.safeSteamID( pl:SteamID() ) .. "/permissions.txt", "DATA" ) then
		local Permissions = von.deserialize( file.Read( "anus/users/" .. anus.safeSteamID( pl:SteamID() ) .. "/permissions.txt", "DATA" ) )
	
		pl.anusPerms = Permissions
	end
	
	hook.Call( "anus_PlayerFullyLoaded", nil, pl )
end )














local aids = true
if aids then return end

util.AddNetworkString( "anus_playerperms" )
util.AddNetworkString( "anus_clearplayerperms" )
util.AddNetworkString( "anus_requestusers" )
util.AddNetworkString( "anus_broadcastusers" )
util.AddNetworkString( "anus_networkusergroup" )
util.AddNetworkString( "anus_requestgroups" )
util.AddNetworkString( "anus_broadcastgroups" )

function anusBroadcastUsers( pl )
	net.Start( "anus_broadcastusers" )
		net.WriteUInt( table.Count( anus.Users ), 10 )
		for k,v in next, anus.Users do
			net.WriteString( v.group )
			net.WriteString( k )
			if v.name then
				net.WriteString( v.name )
			else
				net.WriteString( k )
			end
			net.WriteString( v.expiretime or "0" )
		end
	net.Send( pl )
end

function anusNetworkUserGroup( pl, steamid )
	local Info = anus.Users[ steamid ]
	if not Info then
		Error( "NO INFO ON THIS GUY.. - " .. steamid .. " -- supposed to send to player " .. pl:Nick() .. " (" .. pl:SteamID() .. ")\n" )
		Error( "This could just be you setting someone to user? Report to github how this occured\n" )
		
		Info = { group = "user" }
		--return
	end
	net.Start( "anus_networkusergroup" )
		net.WriteString( Info.group )
		net.WriteString( steamid )
		if Info.name then
			net.WriteString( Info.name )
		else
			net.WriteString( steamid )
		end
		net.WriteString( Info.expiretime or "0" )
	net.Send( pl )
end

	-- ok so what we want
	-- send players another players (or themselves) basic info
	--		What group
	--		Are they perma or are they temporary, if so, how much time let
	--		Are they considered admin
	--		Are they considered superadmin
	--		Table of permissions
	--	 Return 
--function anusSendPlayerPerms( 

function anusSendPlayerPerms( ent, save, time, bno_broadcast, target )
	print( "ent ", ent )

	local Send = {}
	local SendToEnt = false
	if not bno_broadcast then
		print( "its a broadcast." )
		for k,v in ipairs( player.GetAll() ) do
			--if v.anusUserGroup and anus.Groups[ v.anusUserGroup ] and anus.Groups[ v.anusUserGroup ][ "isadmin" ] then
			if v:hasAccess( "seeusergroups" ) then
				Send[ #Send + 1 ] = v
				if v == ent then SendToEnt = true end
			end
		end
	end

	if SendToEnt then
		for k,v in next, Send do
			net.Start( "anus_playerperms" )
				print( "entity writing ", v )
				net.WriteEntity( v )
				net.WriteString( v.anusUserGroup or "user" )
				net.WriteUInt( time or 0, 18 )
				net.WriteBit( anus.Groups[ v.anusUserGroup ].isadmin or false )
				net.WriteBit( anus.Groups[ v.anusUserGroup ].issuperadmin or false )
				
				-- Changed 12/4/2016, this wasn't formatted correctly with the res.t
				-- SHINYCOW   if something breaks
				--net.WriteTable( v.Perms )
				net.WriteUInt( table.Count( v.Perms ), 10 )
				for k,v in next, v.Perms do
					net.WriteString( k )
					net.WriteBit( v )
				end
			net.Send( ent )
		end
	else
		net.Start( "anus_clearplayerperms" )
		net.Send( ent )
	end

	local Send_Pp = table.Copy( Send )
	Send_Pp[ #Send_Pp + 1 ] = ent

	net.Start( "anus_playerperms" )
		net.WriteEntity( ent )
		net.WriteString( ent.anusUserGroup or "user" )
		--net.WriteUInt( v == self and ((save and time) and time) or 0, 18 )
		net.WriteUInt( time or 0, 18 )
		net.WriteBit( anus.Groups[ ent.anusUserGroup ].isadmin or false )
		net.WriteBit( anus.Groups[ ent.anusUserGroup ].issuperadmin or false )

		--net.WriteTable( ent.Perms )
		net.WriteUInt( table.Count( ent.Perms ), 10 )
		for k,v in next, ent.Perms do
			net.WriteString( k )
			net.WriteBit( v )
		end
	net.Send( Send_Pp )

	return Send
end

net.Receive( "anus_requestusers", function( len, pl )
	if not pl:hasAccess( "configuregroups" ) then return end

	anusBroadcastUsers( pl )
end )

function anusBroadcastGroups( pl )
	--[[net.Start("anus_broadcastgroups")
		net.WriteUInt( table.Count(anus.Groups), 8 )
		for k,v in next, anus.Groups do
			net.WriteString( k )
			net.WriteString( v.name )
			net.WriteUInt( table.Count( v.Permissions ), 8 )
			for a,b in next, v.Permissions do
				net.WriteString( a )
				net.WriteString
			net.WriteString( v.time )
			net.WriteString( v.admin )
			net.WriteString( v.admin_steamid )
		end
	net.Send( pl )]]

	net.Start( "anus_broadcastgroups" )
		net.WriteTable( anus.Groups )
	net.Send( pl )
end

net.Receive( "anus_requestgroups" , function( len, pl )
	if not pl:hasAccess( "addgroup" ) then return end

	anusBroadcastGroups( pl )
end )

local Network =
{
[ "unban" ] = "Bans",
[ "pluginload" ] = "Plugins",
}

local function anus_OnAuthenticated( pl )
	if anus.Users and anus.Users[ pl:SteamID() ] then
		if anus.Users[ pl:SteamID() ].time then
				-- base_sv.lua takes care of the rest
			if os.time() <= anus.Users[ pl:SteamID() ].time then
				pl:SetUserGroup( anus.Users[ pl:SteamID() ].group )
			end
		else
			pl:SetUserGroup( anus.Users[ pl:SteamID() ].group, true )
		end
	else
		pl:SetUserGroup( "user" )
	end

	local FakeGroups = { "user" }
	pl:SetNWString( "UserGroup", FakeGroups[ math.random(1, #FakeGroups) ] )

	pl:assignID()
end

hook.Add( "PlayerSpawn", "anus_authenticateplayer", function( pl )
	if not pl.HasAuthenticated then
		timer.Simple( 1.2, function()
			if not IsValid( pl ) then return end

			hook.Call( "anus_PlayerAuthenticated", nil, pl )
			anus_OnAuthenticated( pl )
		end )
		pl.HasAuthenticated = true
	end
end )

hook.Add( "anus_PlayerAuthenticated", "anus_networktables", function( pl )
	local Count = 0
	for k,v in next, Network do
		Count = Count + 1
		timer.createPlayer( pl, "networktables" .. k, 0.5 * Count, 1, function()
				-- can't be arsed to rewrite this
				-- but i've decided that everyone should be able to see which plugins exist and are loaded/unloaded
			if pl:hasAccess( k ) or k == "pluginload" then
				_G[ "anusBroadcast" .. v ]( pl )
			end
		end )
	end

	timer.createPlayer( pl, "networktablesgroupsusers", 0.35, 1, function()
		anusBroadcastGroups( pl )

		if pl:isAnusSendable() then
			anusBroadcastUsers( pl )
			anusSendPlayerPerms( pl, nil, nil, true )
			for k,v in next, player.GetAll() do
				if v == pl then continue end

				timer.createPlayer( pl, "networktablesperms" .. v:UserID(), 0.3 * k, 1, function()
					anusSendPlayerPerms( v, nil, nil, false, pl )
				end )
			end
			hook.Call( "anus_PlayerFullyLoaded", nil, pl )
		end
	end )

	file.CreateDir( "anus/users/" .. anus.safeSteamID( pl:SteamID() ) )
end )