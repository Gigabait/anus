local _R = debug.getregistry()

local function anusBroadcastUsers( pl )
	net.Start( "anus_broadcastusers" )
		net.WriteUInt( table.Count( anus.Users ), 8 )
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

	-- let's not broadcast our group, hm? c:
function _R.Player:SetUserGroup( group, save, time )
	if not anus.Groups[ group ] then return end
	if not self.HasAuthed then return end
	if game.SinglePlayer() then group = "owner" end
	if self:IsTempUser() then
		anus.TempUsers[ self:SteamID() ] = nil
		self.UserGroup = "user"
	end
		-- temp commented out?
	--if self.UserGroup and self.UserGroup == group then return end
	
	self.Perms = {}
	if group == "owner" then
		for k,v in next, anus.Plugins do
			self.Perms[ k ] = true
		end
	else
		for k,v in next, anus.Groups[ group ].Permissions do
			self.Perms[ k ] = v
		end
	end
	self.UserGroup = group
	
	local send = {}
	for k,v in next, player.GetAll() do
		if v.UserGroup and anus.Groups[ v.UserGroup ] and anus.Groups[ v.UserGroup ][ "isadmin" ] then
			send[ #send + 1 ] = v
		end
	end

	local send_pp = send
	send_pp[ #send_pp + 1 ] = self
	for _,v in next, send do
		net.Start( "anus_playerperms" )
			net.WriteEntity( v )
			net.WriteString( v.UserGroup )
			net.WriteUInt( v == self and ((save and time) and time) or 0, 18 )
			net.WriteBit( anus.Groups[ v.UserGroup ].isadmin or false )
			net.WriteBit( anus.Groups[ v.UserGroup ].issuperadmin or false )
			
			net.WriteUInt( table.Count( v.Perms ), 8 )
			for a,b in next, v.Perms do
				net.WriteString( a )
				net.WriteString( tostring( b ) )
			end
		net.Send( send_pp )
	end
	
	if save then
		if time then
			anus.Users[ self:SteamID() ] = {group = group, name = self:Nick(), time = os.time() + time, promoted_year = os.date("%Y"), promoted_month = os.date("%m"), promoted_day = os.date("%m")}
			anus.TempUsers[ self:SteamID() ] = {group = group, name = self:Nick(), time = os.time() + time, promoted_year = os.date("%Y"), promoted_month = os.date("%m"), promoted_day = os.date("%m")}
		else
			if group == "user" then
				for k,v in next, anus.Users do
					if k == self:SteamID() then
						anus.Users[ k ] = nil
						break
					end
				end
			else
				anus.Users[ self:SteamID() ] = {group = group, name = self:Nick()}
			end
		end
		
		file.Write("anus/users.txt", von.serialize( anus.Users ))
	end
	

	timer.Simple(0.1, function()
		for k,v in next, send do
			anusBroadcastUsers( v )
		end
	end)
		
end

	-- For players offline
function anus.SetPlayerGroup( steamid, group, time )
	if not anus.Groups[ group ] then return end
	
	if group != "user" then
		if anus.Users[ steamid ] then		
			anus.Users[ steamid ] = {group = group, name = anus.Users[ steamid ].name, time = time and os.time() + time or nil, promoted_year = os.date("%Y"), promoted_month = os.date("%m"), promoted_day = os.date("%m")}
		else
			anus.Users[ steamid ] = {group = group, name = steamid, time = time and os.time() + time or nil, promoted_year = os.date("%Y"), promoted_month = os.date("%m"), promoted_day = os.date("%m")}
		end
		
		if time then
			anus.TempUsers[ steamid ] = {group = group, name = steamid, time = os.time() + time, promoted_year = os.date("%Y"), promoted_month = os.date("%m"), promoted_day = os.date("%m")}
		end
	else
		anus.Users[ steamid ] = nil
	end
	
	file.Write("anus/users.txt", von.serialize( anus.Users ))
	
	local send = {}
	for k,v in next, player.GetAll() do
		if v.UserGroup and anus.Groups[ v.UserGroup ] and anus.Groups[ v.UserGroup ][ "isadmin" ] then
			send[ #send + 1 ] = v
		end
	end
	timer.Simple(0.1, function()
		for k,v in next, send do
			anusBroadcastUsers( v )
		end
	end)
end
	
function _R.Entity:IsGreaterThan( target )
	if not IsValid(self) then return true end
	if not anus.Groups[ self.UserGroup or "user" ] then return false end

	if anus.GroupHasInheritanceFrom( self.UserGroup or "user", target.UserGroup or "user" ) then
		return true
	end
	
	return false
end
function _R.Entity:IsEqualTo( target )
	if not IsValid(self) then return true end
	if not anus.Groups[ self.UserGroup or "user" ] then return false end

	if self.UserGroup == target.UserGroup then return true end
	
	return false
end
function _R.Entity:IsGreaterOrEqualTo( target )
	if not IsValid(self) then return true end
	if not anus.Groups[ self.UserGroup or "user" ] then return false end

	if anus.GroupHasInheritanceFrom( self.UserGroup or "user", target.UserGroup or "user", true ) then
		return true
	end
	
	return false
end
function _R.Entity:CanTargetPlayer( target, cmd )
	if not IsValid(self) then return true end
	if not target or not cmd or not IsValid(target) then return false end
	if not self.HasAuthed then return false end
	
	return true
end

	-- check immunity
function _R.Entity:HasAccess( plugin )
	if not IsValid( self ) then return true end
	if not self.Perms then return false end
	if self.Perms[ plugin ] then return true end
	if self.UserGroup == "owner" then return true end

	return false
end

_R.Player.OldAdmin = _R.Player.OldAdmin or _R.Player.IsAdmin
_R.Player.OldSuperAdmin = _R.Player.OldSuperAdmin or _R.Player.IsSuperAdmin
function _R.Entity:IsAdmin() if not IsValid(self) then return true end return false end
function _R.Player:IsAdmin()
	if not IsValid(self) then return true end
	return self.UserGroup and anus.Groups[ self.UserGroup ].isadmin or self:OldAdmin()
end
function _R.Entity:IsSuperAdmin() if not IsValid(self) then return true end return false end
function _R.Player:IsSuperAdmin()
	if not IsValid(self) then return true end
	return self.UserGroup and anus.Groups[ self.UserGroup ].issuperadmin or self:OldSuperAdmin()
end
_R.Player.OldIsUserGroup = _R.Player.OldIsUserGroup or _R.Player.IsUserGroup
function _R.Player:IsUserGroup( group )
	if not group then return false end
	return self.UserGroup and self.UserGroup == group or self:OldIsUserGroup()
end
_R.Player.OldGetUserGroup = _R.Player.OldGetUserGroup or _R.Player.GetUserGroup
function _R.Player:GetUserGroup()
	return self.UserGroup or self:OldGetUserGroup()
end

	-- Checks if a player is in this group
	-- or inherits from this group
function _R.Player:CheckGroup( group )
	return anus.GroupHasInheritanceFrom( self.UserGroup, group, true )
end

_R.Player.OldChatPrintP = _R.Player.OldChatPrintP or _R.Player.ChatPrint
_R.Entity.OldChatPrint = _R.Entity.OldChatPrint or _R.Player.ChatPrint
function _R.Entity:ChatPrint( str )
	if not IsValid( self ) then
		print( str )
	else
		self:OldChatPrintP( str )
	end
end
_R.Entity.OldPrintMessage = _R.Entity.OldPrintMessage or _R.Player.PrintMessage
function _R.Entity:PrintMessage( type, msg )
	if not IsValid( self ) then
		print( msg )
	else
		self:OldPrintMessage( type, msg )
	end
end

function _R.Entity:IsTempUser()
	return anus.TempUsers[ self:SteamID() ] != nil
end
function anus.IsTempUser( steamid )
	return anus.TempUsers[ steamid ] != nil
end

_R.Player.OldSteamIDP = _R.Player.OldSteamIDP or _R.Player.SteamID
_R.Entity.OldSteamID = _R.Entity.OldSteamID or _R.Player.SteamID
function _R.Entity:SteamID()
	if not IsValid( self ) then
		return "CONSOLE"
	else
		return self:OldSteamIDP()
	end
end

_R.Player.OldNickP = _R.Player.OldNickP or _R.Player.Nick
_R.Entity.OldNick = _R.Entity.OldNick or _R.Player.Nick
function _R.Entity:Nick()
	if not IsValid(self) then
		return "CONSOLE"
	else
		return self:OldNickP()
	end
end

function _R.Entity:Team()
	return 0
end

function _R.Player:DisableSpawning()
	self.bNoSpawning = true
end
function _R.Player:EnableSpawning()
	self.bNoSpawning = false
end
function _R.Player:CanSpawn()
	return not self.bNoSpawning 
end

hook.Add( "PlayerSpawnObject", "anus_disablespawning", function( pl )
	if not pl:CanSpawn() then return false end
end )
if not oldnumpadActivate and SERVER then
	oldnumpadActivate = numpad.Activate
	function numpad.Activate( pl, num, bIsButton )
		if not pl:CanSpawn() then return end
		
		oldnumpadActivate( pl, num, bIsButton )
	end
end
	
	-- Player UniqueIDs
	-- This is assigned to admins.
	-- Regenerated each reconnect.
local function CreateID()
	local id = string.char( math.random( 97, 122 ) )
	for i=1,6 do
		local rand = math.random( 1, 3 )
		rand = rand != 1 and math.random( 3, 99 ) or string.char( math.random( 97, 122 ) )
		id = id .. rand
		if i % 2 == 0 and i != 6 then
			id = id .. "-"
		end
	end
	id = id .. string.char( math.random( 97, 122 ) )

	return id
end
function _R.Player:AssignID()
	local id = CreateID()
	self:ChatPrint( "id   " .. id )
end