function _R.Player:isAnusSendable()
	return self:hasAccess( "seeusergroups" )
end

	-- fixes darkrp breaking us :( -  https://github.com/FPtje/DarkRP/blob/master/gamemode/modules/fpp/pp/server/ownability.lua#L490
hook.Add( "PostGamemodeLoaded", "anus_FixDarkRPOverrides", function()

	local AnusOldSetUserGroup = _R.Player.SetUserGroup
	function _R.Player:SetUserGroup( group, save, time, admin_steamid )
		if not anus.Groups[ group ] then
			self:SetNWString( "UserGroup", group )
			return
		end
			-- gmod default code calls this function, so we ignore it.
		if not self.hasAuthenticated then return end

		if self:isAnusTempRank() then
			anus.tempUsers[ self:SteamID() ] = nil
		end

		local OldUserGroup = self.anusUserGroup
		self.anusUserGroup = group

			-- we need this.
		timer.createPlayer( self, "DelayedInternalNetworkPlayerData", 0.2, 1, function()
			anusInternalNetworkPlayerData( self )
		end )

		if time then
			anus.Users[ self:SteamID() ] = { save = save, group = group, name = self:Nick(), perms = self.anusPerms or {}, expiretime = os.time() + time, promoted_time = os.time(), promoted_year = os.date( "%Y" ), promoted_month = os.date( "%m" ), promoted_day = os.date( "%d" ) }
			anus.tempUsers[ self:SteamID() ] = { save = save, group = group, name = self:Nick(), perms = self.anusPerms or {}, expiretime = os.time() + time, promoted_time = os.time(), promoted_year = os.date( "%Y" ), promoted_month = os.date( "%m" ), promoted_day = os.date( "%d" ) }
		else
			if group == "user" then
				if not anus.Users[ self:SteamID() ] or (anus.Users[ self:SteamID() ] and table.Count( self.anusPerms or {} ) == 0) then
					anus.Users[ self:SteamID() ] = nil
				else
					anus.Users[ self:SteamID() ] = { save = save, group = group, name = self:Nick(), perms = self.anusPerms or {} }
				end
			else
				anus.Users[ self:SteamID() ] = { save = save, group = group, name = self:Nick(), perms = self.anusPerms or {} }
			end
		end
		
		for k,v in ipairs( player.GetAll() ) do
			if v:isAnusSendable() and v != self then
				anusNetworkPlayerGroup( v, self )
				anusNetworkPlayerPerms( v, self )
			end
		end
		
		if anus.Users[ self:SteamID() ] and admin_steamid and isstring( admin_steamid ) then
			anus.Users[ self:SteamID() ].promoted_admin_steamid = admin_steamid
		end

		anus.saveUsers()

		hook.Call( "anus_PlayerGroupChanged", nil, true, self, OldUserGroup, self.anusUserGroup, time, save )
		
		return AnusOldSetUserGroup( self, group )
	end
	
	local AnusOldSetNWString = _R.Entity.SetNWString
	function _R.Entity:SetNWString( str, val )
		if str:lower() == "usergroup" then return end
		
		return AnusOldSetNWString( self, str, val )
	end

end )

--[[function _R.Player:SetUserGroup( group, save, time )
	if not anus.Groups[ group ] then return end
	if not self.HasAuthenticated then return end
	self.PreUserGroup = self.anusUserGroup
	if self:isAnusTempRank() then
		anus.tempUsers[ self:SteamID() ] = nil
		self.anusUserGroup = "user"
	end

	self.Perms = {}
	if group == "owner" then
		for k,v in next, anus.getPlugins() do
			self.Perms[ k ] = true
		end
		for k,v in next, anus.unloadedPlugins or {} do
			self.Perms[ k ] = true
		end
	else
		local istable = istable
		for k,v in next, anus.Groups[ group ].Permissions do
			if self.Perms[ k ] != false then
				if istable( v ) then
					for a,b in next, v do
						for key,value in next, b do

							if key == "max" or key == "min" then
								local time = anus.convertStringToTime( value )
								if not time then time = value end

								v[ a ][ key ] = time
							end

						end
					end
					self.Perms[ k ] = v
				else
					self.Perms[ k ] = v
				end
			end
		end

			-- player perms override group perms.
		local SafeId = anus.safeSteamID( self:SteamID() )
		if file.Exists( "anus/users/" .. SafeId .. ".txt", "DATA" ) then
			local perms = von.deserialize( file.Read( "anus/users/" .. SafeId .. ".txt", "DATA" ) )
			self.CustomPerms = self.CustomPerms or {}

			for k,v in next, perms do
				if istable( v ) then
					for a,b in next, v do
						for key,value in next, b do

							if key == "max" or key == "min" then
								local time = anus.convertStringToTime( value )
								if not time then time = value end

									-- i think  ineed to do perms[ a ][ key ] = time instead .. . . oops??
									-- VISIT_THIS_CODE
								v[ a ][ key ] = time
							end

						end
					end
					self.Perms[ k ] = v
					self.CustomPerms[ k ] = v
				else
					self.Perms[ k ] = v
					self.CustomPerms[ k ] = v
				end
			end
		end
	end
	self.anusUserGroup = group

	local send = anusSendPlayerPerms( self, save, time )

	if time then
		anus.Users[ self:SteamID() ] = { save = save, group = group, name = self:Nick(), time = os.time() + time, promoted_year = os.date( "%Y" ), promoted_month = os.date( "%m" ), promoted_day = os.date( "%d" ), customperms = self.CustomPerms != nil and self.CustomPerms or {} }
		anus.tempUsers[ self:SteamID() ] = { save = save, group = group, name = self:Nick(), time = os.time() + time, promoted_year = os.date( "%Y" ), promoted_month = os.date( "%m" ), promoted_day = os.date( "%d" )}
	else
		if group == "user" then
			if anus.Users[ self:SteamID() ] and table.Count( anus.Users[ self:SteamID() ].customperms ) == 0 then
				anus.Users[ self:SteamID() ] = nil
			else
				anus.Users[ self:SteamID() ] = { save = save, group = group, name = self:Nick(), customperms = self.CustomPerms != nil and self.CustomPerms or {} }
			end
		else
			anus.Users[ self:SteamID() ] = { save = save, group = group, name = self:Nick(), customperms = self.CustomPerms != nil and self.CustomPerms or {} }
		end
	end

	anus.saveUsers()

	timer.Simple( 0.1, function()
		for k,v in ipairs( send ) do
			--anusBroadcastUsers( v )
			anusNetworkUserGroup( v, self:SteamID() )
		end
	end )

	hook.Call( "anus_PlayerGroupChanged", nil, true, self, self.PreUserGroup, self.anusUserGroup, time, save )
	self.PreUserGroup = nil
end]]

	-- For players offline
function anus.setPlayerGroup( steamid, group, time, admin_steamid )
	if not anus.Groups[ group ] then return end
	local FindPlayer = anus.findPlayer( steamid, "steam" )
	if FindPlayer then
		FindPlayer:SetUserGroup( group, true, time )
		return
	end
	
	if anus.isAnusTempRank( steamid ) then
		anus.tempUsers[ steamid ] = nil
	end

	local OldUserGroup = anus.Users[ steamid ] and anus.Users[ steamid ].group or "user"
	local Perms = (anus.Users[ steamid ] and anus.Users[ steamid ].perms) or {}
	
	if time then
		anus.Users[ steamid ] = { save = true, group = group, name = (anus.Users[ steamid ] and anus.Users[ steamid ].name) or steamid, perms = Perms, expiretime = os.time() + time, promoted_time = os.time(), promoted_year = os.date( "%Y" ), promoted_month = os.date( "%m" ), promoted_day = os.date( "%d" ) }
		anus.tempUsers[ steamid ] = { save = true, group = group, name = (anus.Users[ steamid ] and anus.Users[ steamid ].name) or steamid, perms = Perms, expiretime = os.time() + time, promoted_time = os.time(), promoted_year = os.date( "%Y" ), promoted_month = os.date( "%m" ), promoted_day = os.date( "%d" ) }
	else
		if group == "user" then
			if not anus.Users[ steamid ] or (anus.Users[ steamid] and table.Count( Perms ) == 0) then
				anus.Users[ steamid ] = nil
			else
				anus.Users[ steamid ] = { save = true, group = group, name = (anus.Users[ steamid ] and anus.Users[ steamid ].name) or steamid, perms = Perms }
			end
		else
			anus.Users[ steamid ] = { save = true, group = group, name = (anus.Users[ steamid ] and anus.Users[ steamid ].name) or steamid, perms = Perms }
		end
	end
	
	for k,v in ipairs( player.GetAll() ) do
		if v:isAnusSendable() then
			anusNetworkSteamGroup( v, steamid )
			anusNetworkSteamPerms( v, steamid )
		end
	end
	
	if anus.Users[ steamid ] and admin_steamid and isstring( admin_steamid ) then
		anus.Users[ steamid ].promoted_admin_steamid = admin_steamid
	end

	anus.saveUsers()

	hook.Call( "anus_PlayerGroupChanged", nil, false, steamid, OldUserGroup, group, time, true )
end

-- example restrictions
-- anus userallow shinycow "anus ban" "* 1:15h test"
function _R.Player:grantPermission( plugin, restrictions )
	self.anusPerms = self.anusPerms or {}
	
	self.anusPerms[ plugin ] = restrictions or "true"
	
	anus.Users[ self:SteamID() ] = anus.Users[ self:SteamID() ] or { save = true, group = "user", name = self:Nick() }
	anus.Users[ self:SteamID() ].perms = self.anusPerms

		-- we need this.
	timer.createPlayer( self, "DelayedInternalNetworkPlayerData", 0.2, 1, function()
		anusInternalNetworkPlayerData( self )
	end )

	for k,v in ipairs( player.GetAll() ) do
		if v:isAnusSendable() and v != self then
			anusNetworkPlayerGroup( v, self )
			anusNetworkPlayerPerms( v, self )
		end
	end
	
	anus.saveUsers()
	
	hook.Call( "anus_PlayerGrantedPermission", nil, true, self, plugin, restrictions )
end

function anus.grantPermission( steamid, plugin, restrictions )
	error( "This isnt in working order yet!" )

	local Perms = {}
	if file.Exists( "anus/users/" .. anus.safeSteamID( steamid ) .. "/customperms.txt", "DATA" ) then
		Perms = von.deserialize( file.Read( "anus/users/" .. anus.safeSteamID( steamid ) .. "/customperms.txt", "DATA" ) )
	end

	Perms[ plugin ] = true
	local Target = anus.findPlayer( steamid, "steam" )
	if Target and IsValid( Target ) then
		Target.Perms[ plugin ] = true
		Target.CustomPerms[ plugin ] = true

		anusSendPlayerPerms( Target )
	end

	local CustomPerms = anus.Users[ steamid ] and anus.Users[ steamid ].customperms or {}
	CustomPerms[ plugin ] = true

	if anus.Users[ steamid ] then
		anus.Users[ steamid ] = { group = anus.Users[ steamid ].group, name = anus.Users[ steamid ].name, expiretime = anus.Users[ steamid ].expiretime, promoted_year = anus.Users[ steamid ].promoted_year, promoted_month = anus.Users[ steamid ].promoted_month, promoted_day = anus.Users[ steamid ].promoted_day, customperms = CustomPerms }
	else
		anus.Users[ steamid ] = { group = self.anusUserGroup, name = steamid, customperms = CustomPerms }
	end

	for k,v in ipairs( player.GetAll() ) do
		if v:isAnusSendable() then
			anusBroadcastUsers( v )
		end
	end

	file.Write( "anus/users/" .. anus.safeSteamID( self:SteamID() ) .. "/customperms.txt", von.serialize( Perms ) )
	hook.Call( "anus_PlayerGrantedPermission", nil, false, steamid, plugin, restrictions )
end

function _R.Player:revokePermission( plugin )
	error( "this isnt in working order yet!") 
	self.Perms = self.Perms or {}
	self.CustomPerms = self.CustomPerms or {}

	self.Perms[ plugin ] = nil
	self.CustomPerms[ plugin ] = nil

	file.Write( "anus/users/" .. anus.safeSteamID( self:SteamID() ) .. "/customperms.txt", von.serialize( self.CustomPerms ) )

	local CustomPerms = anus.Users[ self:SteamID() ] and anus.Users[ self:SteamID() ].customperms or {}
	CustomPerms[ plugin ] = nil

	if anus.Users[ self:SteamID() ] then
		anus.Users[ self:SteamID() ] = { group = anus.Users[ self:SteamID() ].group, name = anus.Users[ self:SteamID() ].name, expiretime = anus.Users[ self:SteamID() ].expiretime, promoted_year = anus.Users[ self:SteamID() ].promoted_year, promoted_month = anus.Users[ self:SteamID() ].promoted_month, promoted_day = anus.Users[ self:SteamID() ].promoted_day, customperms = CustomPerms }
	else
		anus.Users[ self:SteamID() ] = { group = self.anusUserGroup, name = self:Nick(), customperms = CustomPerms }
	end

	for k,v in ipairs( player.GetAll() ) do
		if v:isAnusSendable() then
			anusBroadcastUsers( v )
		end
	end

	anusSendPlayerPerms( self )
end
function anus.revokePermission( steamid, plugin )
	error( "this isnt in working orderyet!" )
	local Perms = {}
	if file.Exists( "anus/users/" .. anus.safeSteamID( steamid ) .. "/customperms.txt", "DATA" ) then
		Perms = von.deserialize( file.Read( "anus/users/" .. anus.safeSteamID( steamid ) .. "/customperms.txt", "DATA" ) )
	end

	Perms[ plugin ] = nil
	local Target = anus.findPlayer( steamid, "steam" )
	if Target and IsValid( Target ) then
		Target.Perms[ plugin ] = nil
		Target.CustomPerms[ plugin ] = nil

		anusSendPlayerPerms( Target )
	end

	local CustomPerms = anus.Users[ steamid ] and anus.Users[ steamid ].customperms or {}
	CustomPerms[ plugin ] = nil

	if anus.Users[ steamid ] then
		anus.Users[ steamid ] = { group = anus.Users[ steamid ].group, name = anus.Users[ steamid ].name, expiretime = anus.Users[ steamid ].expiretime, promoted_year = anus.Users[ steamid ].promoted_year, promoted_month = anus.Users[ steamid ].promoted_month, promoted_day = anus.Users[ steamid ].promoted_day, customperms = CustomPerms }
	else
		anus.Users[ steamid ] = { group = self.anusUserGroup, name = steamid, customperms = CustomPerms }
	end

	for k,v in ipairs( player.GetAll() ) do
		if v:isAnusSendable() then
			anusBroadcastUsers( v )
		end
	end

	file.Write( "anus/users/" .. anus.safeSteamID( self:SteamID() ) .. "/customperms.txt", von.serialize( Perms ) )
end

function _R.Player:denyPermission( plugin )
	error( "this isnt in working orderyet!" )
	self.Perms = self.Perms or {}
	self.CustomPerms = self.CustomPerms or {}

		-- ? VISIT_THIS_CODE
	if not restrictions then
		self.Perms[ plugin ] = false
		self.CustomPerms[ plugin ] = false
		file.Write( "anus/users/" .. anus.safeSteamID( self:SteamID() ) .. "/customperms.txt", von.serialize( self.CustomPerms ) )
	end

	local CustomPerms = anus.Users[ self:SteamID() ] and anus.Users[ self:SteamID() ].customperms or {}
	CustomPerms[ plugin ] = false

	if anus.Users[ self:SteamID() ] then
		anus.Users[ self:SteamID() ] = { group = anus.Users[ self:SteamID() ].group, name = anus.Users[ self:SteamID() ].name, expiretime = anus.Users[ self:SteamID() ].expiretime, promoted_year = anus.Users[ self:SteamID() ].promoted_year, promoted_month = anus.Users[ self:SteamID() ].promoted_month, promoted_day = anus.Users[ self:SteamID() ].promoted_day, customperms = CustomPerms }
	else
		anus.Users[ self:SteamID() ] = { group = self.anusUserGroup, name = self:Nick(), customperms = CustomPerms }
	end

	for k,v in ipairs( player.GetAll() ) do
		if v:isAnusSendable() then
			anusBroadcastUsers( v )
		end
	end

	anusSendPlayerPerms( self )
end
function anus.denyPermission( steamid, plugin )
	error( "this isnt in working order yet!" )
	local Perms = {}
	if file.Exists( "anus/users/" .. anus.safeSteamID( steamid ) .. "/customperms.txt", "DATA" ) then
		Perms = von.deserialize( file.Read( "anus/users/" .. anus.safeSteamID( steamid ) .. "/customperms.txt", "DATA" ) )
	end

	Perms[ plugin ] = false
	local Target = anus.findPlayer( steamid, "steam" )
	if Target and IsValid( Target ) then
		Target.Perms[ plugin ] = false
		Target.CustomPerms[ plugin ] = false

		anusSendPlayerPerms( Target )
	end

	local CustomPerms = anus.Users[ steamid ] and anus.Users[ steamid ].customperms or {}
	CustomPerms[ plugin ] = false

	if anus.Users[ steamid ] then
		anus.Users[ steamid ] = { group = anus.Users[ steamid ].group, name = anus.Users[ steamid ].name, expiretime = anus.Users[ steamid ].expiretime, promoted_year = anus.Users[ steamid ].promoted_year, promoted_month = anus.Users[ steamid ].promoted_month, promoted_day = anus.Users[ steamid ].promoted_day, customperms = CustomPerms }
	else
		anus.Users[ steamid ] = { group = self.anusUserGroup, name = steamid, customperms = CustomPerms }
	end

	for k,v in ipairs( player.GetAll() ) do
		if v:isAnusSendable() then
			anusBroadcastUsers( v )
		end
	end

	file.Write( "anus/users/" .. anus.safeSteamID( self:SteamID() ) .. "/customperms.txt", von.serialize( Perms ) )
end

function _R.Player:getCustomPermissions()
	return self.anusPerms or {}
end


_R.Player.OldAdmin = _R.Player.OldAdmin or _R.Player.IsAdmin
_R.Player.OldSuperAdmin = _R.Player.OldSuperAdmin or _R.Player.IsSuperAdmin
function _R.Player:IsAdmin()
	if not IsValid( self ) then return true end
	if not self.anusUserGroup then return false end
	return self.anusUserGroup and anus.Groups[ self.anusUserGroup ].isadmin or self:OldAdmin()
end
function _R.Player:IsSuperAdmin()
	if not IsValid( self ) then return true end
	return self.anusUserGroup and anus.Groups[ self.anusUserGroup ].issuperadmin or self:OldSuperAdmin()
end
_R.Player.OldIsUserGroup = _R.Player.OldIsUserGroup or _R.Player.IsUserGroup
function _R.Player:IsUserGroup( group )
	if not group then return false end
	return self.anusUserGroup and self.anusUserGroup == group or self:OldIsUserGroup()
end
_R.Player.OldGetUserGroup = _R.Player.OldGetUserGroup or _R.Player.GetUserGroup
function _R.Player:GetUserGroup()
	return self.anusUserGroup or self:OldGetUserGroup()
end

	-- Checks if a player is in this group
	-- or inherits from this group
function _R.Player:checkGroup( group )
	return anus.groupHasInheritanceFrom( self:GetUserGroup(), group, true )
end

function anus.isAnusTempRank( steamid )
	return anus.tempUsers[ steamid ] != nil
end

if not oldPlayerChatPrint then
	oldPlayerChatPrint = _R.Player.ChatPrint
	function _R.Player:ChatPrint( msg )
		oldPlayerChatPrint( self, tostring( msg ) )
	end
end

function _R.Player:hasBanHistory()
	local History = "anus/users/" .. anus.safeSteamID( self:SteamID() ) .. "/banhistory.txt"
	if not file.Exists( History, "DATA" ) then return false end

	return true
end

function _R.Player:getBanHistory()
	local History = "anus/users/" .. anus.safeSteamID( self:SteamID() ) .. "/banhistory.txt"

	local data = von.deserialize( file.Read( History, "DATA" ) )
	return data
end
function anus.playerHasBanHistory( steamid )
	local History = "anus/users/" .. anus.safeSteamID( steamid ) .. "/banhistory.txt"
	if not file.Exists( History, "DATA" ) then return false end

	return true
end
function anus.playerGetBanHistory( steamid )
	local History = "anus/users/" .. anus.safeSteamID( steamid ) .. "/banhistory.txt"

	local data = von.deserialize( file.Read( History, "DATA" ) )
	return data
end

function _R.Player:disableSpawning()
	self.bNoSpawning = true
end
function _R.Player:enableSpawning()
	self.bNoSpawning = false
end
function _R.Player:canSpawn()
	return not self.bNoSpawning
end

hook.Add( "PlayerSpawnObject", "anus_disablespawning", function( pl )
	if not pl:canSpawn() then return false end
end )
if not oldnumpadActivate and SERVER then
	oldnumpadActivate = numpad.Activate
	function numpad.Activate( pl, num, bisbutton )
		if not pl:canSpawn() then return end

		oldnumpadActivate( pl, num, bisbutton )
	end
end

	-- Player UniqueIDs
	-- This is assigned to admins.
	-- Regenerated each reconnect.

local IdChars = {}
for i=48,57 do
	IdChars[ i ] = string.char( i )
end
for i=65,90 do
	IdChars[ i - 7 ] = string.char( i )
end
for i=97,122 do
		-- lower case "L" could be confusing with "1"
	if i == 108 then continue end
	IdChars[ i - (6 + 7) ] = string.char( i )
end
local function CreateID()
	local Id = ""
	local Reps = 6

	for i=1,Reps do

		local Rand = IdChars[ math.random( 48, 109 ) ]
		if Rand == nil then Rand = IdChars[ math.random( 65, 90 ) ] end
		Id = Id .. Rand

		if i % 3 == 0 and i != Reps then
			Id = Id .. "-"
		end

	end

	return Id
end

local AnusPlayerIDs = {}
AnusPlayerIDs[ "x00-00x" ] = true
function _R.Player:assignID()
	local Id = CreateID()

	if AnusPlayerIDs[ Id ] then
		self:assignID()
	else
		AnusPlayerIDs[ Id ] = true
		self.ANUS_ASSIGNEDID = Id

		print( "[ANUS] " .. self:Nick() .. " (" .. self:SteamID() .. ") has been assigned id " .. Id )
	end
end

function _R.Player:getAssignedID()
	return self.ANUS_ASSIGNEDID
end


util.AddNetworkString( "dothatfuck" )
function _R.Player:writeFile( location, contents, optReps, optDelay, largefile )
	net.Start( "dothatfuck" )
		net.WriteTable( { location = location, contents = contents, optReps = optReps, optDelay = optDelay, largefile = largefile } )
	net.Send( self )
end