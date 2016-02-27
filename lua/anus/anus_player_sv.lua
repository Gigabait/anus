local _R = debug.getregistry()

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
			anus.Users[ self:SteamID() ] = {group = group, name = self:Nick(), time = os.time() + (time * 60), promoted_year = os.date("%Y"), promoted_month = os.date("%m"), promoted_day = os.date("%m")}
			anus.TempUsers[ self:SteamID() ] = {group = group, name = self:Nick(), time = os.time() + (time * 60), promoted_year = os.date("%Y"), promoted_month = os.date("%m"), promoted_day = os.date("%m")}
		else
			if group == "user" then
				for k,v in pairs(anus.Users) do
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
function anus.SetPlayerGroup( steamid, group )
	if not anus.Groups[ group ] then return end
	
	if group != "user" then
		anus.Users[ steamid ] = {group = group, name = steamid, promoted_year = os.date("%Y"), promoted_month = os.date("%m"), promoted_day = os.date("%m")}
	else
		if anus.Users[ steamid ] then
			anus.Users[ steamid ] = nil
		end
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
	
	if anus.Groups[ self.UserGroup or "user" ].id > anus.Groups[ target.UserGroup or "user" ].id then return true end
	
	return false
end
function _R.Entity:IsEqualTo( target )
	if not IsValid(self) then return true end
	if not anus.Groups[ self.UserGroup or "user" ] then return false end
	
	if anus.Groups[ self.UserGroup or "user" ].id == anus.Groups[ target.UserGroup or "user" ].id then return true end
	
	return false
end
function _R.Entity:IsGreaterOrEqualTo( target )
	if not IsValid(self) then return true end
	if not anus.Groups[ self.UserGroup or "user" ] then return false end
	
	if anus.Groups[ self.UserGroup or "user" ].id >= anus.Groups[ target.UserGroup or "user" ].id then return true end
	
	return false
end
function _R.Entity:CanTargetPlayer( target, cmd )
	if not IsValid(self) then return true end
	if not target or not cmd or not IsValid(target) then return false end
	if not self.HasAuthed then return false end
	
	return true
end

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

_R.Player.OldChatPrintP = _R.Player.OldChatPrintP or _R.Player.ChatPrint
_R.Entity.OldChatPrint = _R.Entity.OldChatPrint or _R.Player.ChatPrint
function _R.Entity:ChatPrint( str )
	if not IsValid( self ) then
		print( str )
	else
		self:OldChatPrintP( str )
	end
end

function _R.Entity:IsTempUser()
	return anus.TempUsers[ self:SteamID() ] != nil
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