local _R = debug.getregistry()

--[[local function anusBroadcastUsers( pl )
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
end]]

function _R.Player:IsAnusSendable()
	return self.UserGroup and anus.Groups[ self.UserGroup ] and anus.Groups[ self.UserGroup ][ "isadmin" ]
end

function anusSendPlayerPerms( ent )
	local send = {}
	for k,v in next, player.GetAll() do
		if v.UserGroup and anus.Groups[ v.UserGroup ] and anus.Groups[ v.UserGroup ][ "isadmin" ] then
			send[ #send + 1 ] = v
		end
	end

	local send_pp = table.Copy( send )
	send_pp[ #send_pp + 1 ] = ent
	--for _,v in next, send do
	---	if v.IsBot and v:IsBot() then continue end

		net.Start( "anus_playerperms" )
			net.WriteEntity( ent )
			net.WriteString( ent.UserGroup )
			net.WriteUInt( /*v == self and*/ ((save and time) and time) or 0, 18 )
			net.WriteBit( anus.Groups[ ent.UserGroup ].isadmin or false )
			net.WriteBit( anus.Groups[ ent.UserGroup ].issuperadmin or false )
			
			--[[net.WriteUInt( table.Count( v.Perms ), 8 )
			for a,b in next, v.Perms do
				net.WriteString( a )
				local btype = type( b )
				net.WriteBit( tobool( btype == "table" ) )
				if btype == "table" then
					for key, value in next, b do
						
				net.WriteString( tostring( b ) )
			end]]
			net.WriteTable( ent.Perms )
		net.Send( send_pp )
	--end
	
	return send
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
		for k,v in next, anus.UnloadedPlugins or {} do
			self.Perms[ k ] = true
		end
	else
		local type = type
		for k,v in next, anus.Groups[ group ].Permissions do
			if self.Perms[ k ] != false then
				if type( v ) == "table" then
					for a,b in next, v do
						for key,value in next, b do
						
							if key == "max" or key == "min" then
								local time = anus.ConvertStringToTime( value )
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
		local f = anus.SafeSteamID( self:SteamID() )
		if file.Exists( "anus/users/" .. f .. ".txt", "DATA" ) then
			local perms = von.deserialize( file.Read( "anus/users/" .. f .. ".txt", "DATA" ) )
			self.CustomPerms = self.CustomPerms or {}
			
			local type = type
			for k,v in next, perms do
				if type( v ) == "table" then
					for a,b in next, v do
						for key,value in next, b do
						
							if key == "max" or key == "min" then
								local time = anus.ConvertStringToTime( value )
								if not time then time = value end
								
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
	self.UserGroup = group

	local send = anusSendPlayerPerms( self, save, time )
	
	if save then
		if time then
			anus.Users[ self:SteamID() ] = { group = group, name = self:Nick(), time = os.time() + time, promoted_year = os.date("%Y"), promoted_month = os.date("%m"), promoted_day = os.date("%m"), customperms = self.CustomPerms != nil and self.CustomPerms or {} }
			anus.TempUsers[ self:SteamID() ] = { group = group, name = self:Nick(), time = os.time() + time, promoted_year = os.date("%Y"), promoted_month = os.date("%m"), promoted_day = os.date("%m")}
		else
			if group == "user" then
				for k,v in next, anus.Users do
					if k == self:SteamID() then
						anus.Users[ k ] = nil
						break
					end
				end
			else
				anus.Users[ self:SteamID() ] = { group = group, name = self:Nick(), customperms = self.CustomPerms != nil and self.CustomPerms or {} }
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
			anus.Users[ steamid ] = { group = group, name = anus.Users[ steamid ].name, time = time and os.time() + time or nil, promoted_year = os.date("%Y"), promoted_month = os.date("%m"), promoted_day = os.date("%m"), customperms = anus.Users[ steamid ].customperms }
		else
			anus.Users[ steamid ] = { group = group, name = steamid, time = time and os.time() + time or nil, promoted_year = os.date("%Y"), promoted_month = os.date("%m"), promoted_day = os.date("%m"), customperms = {} }
		end
		
		if time then
			anus.TempUsers[ steamid ] = { group = group, name = steamid, time = os.time() + time, promoted_year = os.date("%Y"), promoted_month = os.date("%m"), promoted_day = os.date("%m") }
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

-- example restrictions
-- anus userallow shinycow "anus ban" "2:min 1s 2:max 10m"
function _R.Player:GrantPermission( plugin, restrictions )
	self.Perms = self.Perms or {}
	self.CustomPerms = self.CustomPerms or {}
	
	if not restrictions then
		self.Perms[ plugin ] = true
		self.CustomPerms[ plugin ] = true
		file.Write( "anus/users/" .. anus.SafeSteamID( self:SteamID() ) .. "/customperms.txt", von.serialize( self.CustomPerms ) )
	end
	
	local customperms = anus.Users[ self:SteamID() ] and anus.Users[ self:SteamID() ].customperms or {}
	customperms[ plugin ] = true

	if anus.Users[ self:SteamID() ] then
		anus.Users[ self:SteamID() ] = { group = anus.Users[ self:SteamID() ].group, name = anus.Users[ self:SteamID() ].name, time = anus.Users[ self:SteamID() ].time, promoted_year = anus.Users[ self:SteamID() ].promoted_year, promoted_month = anus.Users[ self:SteamID() ].promoted_month, promoted_day = anus.Users[ self:SteamID() ].promoted_day, customperms = customperms }
	else
		anus.Users[ self:SteamID() ] = { group = self.UserGroup or "user", name = self:Nick(), customperms = customperms }
	end
	
	anusSendPlayerPerms( self )
	for k,v in next, player.GetAll() do
		if v:IsAnusSendable() then
			anusBroadcastUsers( v )
		end
	end
end
function anus.GrantPermission( steamid, plugin, restrictions )
	local perms = {}
	if file.Exists( "anus/users/" .. anus.SafeSteamID( steamid ) .. "/customperms.txt", "DATA" ) then
		perms = von.deserialize( file.Read( "anus/users/" .. anus.SafeSteamID( steamid ) .. "/customperms.txt", "DATA" ) )
	end
	
	perms[ plugin ] = true
	local target = anus.FindPlayer( steamid, "steam" )
	if target and IsValid( target ) then
		target.Perms[ plugin ] = true
		target.CustomPerms[ plugin ] = true
		
		anusSendPlayerPerms( target )
	end
	
	local customperms = anus.Users[ steamid ] and anus.Users[ steamid ].customperms or {}
	customperms[ plugin ] = true

	if anus.Users[ steamid ] then
		anus.Users[ steamid ] = { group = anus.Users[ steamid ].group, name = anus.Users[ steamid ].name, time = anus.Users[ steamid ].time, promoted_year = anus.Users[ steamid ].promoted_year, promoted_month = anus.Users[ steamid ].promoted_month, promoted_day = anus.Users[ steamid ].promoted_day, customperms = customperms }
	else
		anus.Users[ steamid ] = { group = self.UserGroup, name = steamid, customperms = customperms }
	end
	
	for k,v in next, player.GetAll() do
		if v:IsAnusSendable() then
			anusBroadcastUsers( v )
		end
	end
	
	file.Write( "anus/users/" .. anus.SafeSteamID( self:SteamID() ) .. "/customperms.txt", von.serialize( perms ) )
end

function _R.Player:RevokePermission( plugin )
	self.Perms = self.Perms or {}
	self.CustomPerms = self.CustomPerms or {}
	
	self.Perms[ plugin ] = nil
	self.CustomPerms[ plugin ] = nil
	
	file.Write( "anus/users/" .. anus.SafeSteamID( self:SteamID() ) .. "/customperms.txt", von.serialize( self.CustomPerms ) )
	
	local customperms = anus.Users[ self:SteamID() ] and anus.Users[ self:SteamID() ].customperms or {}
	customperms[ plugin ] = nil

	if anus.Users[ self:SteamID() ] then
		anus.Users[ self:SteamID() ] = { group = anus.Users[ self:SteamID() ].group, name = anus.Users[ self:SteamID() ].name, time = anus.Users[ self:SteamID() ].time, promoted_year = anus.Users[ self:SteamID() ].promoted_year, promoted_month = anus.Users[ self:SteamID() ].promoted_month, promoted_day = anus.Users[ self:SteamID() ].promoted_day, customperms = customperms }
	else
		anus.Users[ self:SteamID() ] = { group = self.UserGroup, name = self:Nick(), customperms = customperms }
	end
	
	for k,v in next, player.GetAll() do
		if v:IsAnusSendable() then
			anusBroadcastUsers( v )
		end
	end
	
	anusSendPlayerPerms( self )
end
function anus.RevokePermission( steamid, plugin )
	local perms = {}
	if file.Exists( "anus/users/" .. anus.SafeSteamID( steamid ) .. "/customperms.txt", "DATA" ) then
		perms = von.deserialize( file.Read( "anus/users/" .. anus.SafeSteamID( steamid ) .. "/customperms.txt", "DATA" ) )
	end
	
	perms[ plugin ] = nil
	local target = anus.FindPlayer( steamid, "steam" )
	if target and IsValid( target ) then
		target.Perms[ plugin ] = nil
		target.CustomPerms[ plugin ] = nil
		
		anusSendPlayerPerms( target )
	end
	
	local customperms = anus.Users[ steamid ] and anus.Users[ steamid ].customperms or {}
	customperms[ plugin ] = nil

	if anus.Users[ steamid ] then
		anus.Users[ steamid ] = { group = anus.Users[ steamid ].group, name = anus.Users[ steamid ].name, time = anus.Users[ steamid ].time, promoted_year = anus.Users[ steamid ].promoted_year, promoted_month = anus.Users[ steamid ].promoted_month, promoted_day = anus.Users[ steamid ].promoted_day, customperms = customperms }
	else
		anus.Users[ steamid ] = { group = self.UserGroup, name = steamid, customperms = customperms }
	end
	
	for k,v in next, player.GetAll() do
		if v:IsAnusSendable() then
			anusBroadcastUsers( v )
		end
	end
	
	file.Write( "anus/users/" .. anus.SafeSteamID( self:SteamID() ) .. "/customperms.txt", von.serialize( perms ) )
end

function _R.Player:DenyPermission( plugin )
	self.Perms = self.Perms or {}
	self.CustomPerms = self.CustomPerms or {}
	
	if not restrictions then
		self.Perms[ plugin ] = false
		self.CustomPerms[ plugin ] = false
		file.Write( "anus/users/" .. anus.SafeSteamID( self:SteamID() ) .. "/customperms.txt", von.serialize( self.CustomPerms ) )
	end
	
	local customperms = anus.Users[ self:SteamID() ] and anus.Users[ self:SteamID() ].customperms or {}
	customperms[ plugin ] = false

	if anus.Users[ self:SteamID() ] then
		anus.Users[ self:SteamID() ] = { group = anus.Users[ self:SteamID() ].group, name = anus.Users[ self:SteamID() ].name, time = anus.Users[ self:SteamID() ].time, promoted_year = anus.Users[ self:SteamID() ].promoted_year, promoted_month = anus.Users[ self:SteamID() ].promoted_month, promoted_day = anus.Users[ self:SteamID() ].promoted_day, customperms = customperms }
	else
		anus.Users[ self:SteamID() ] = { group = self.UserGroup, name = self:Nick(), customperms = customperms }
	end
	
	for k,v in next, player.GetAll() do
		if v:IsAnusSendable() then
			anusBroadcastUsers( v )
		end
	end
	
	anusSendPlayerPerms( self )
end
function anus.DenyPermission( steamid, plugin )
	local perms = {}
	if file.Exists( "anus/users/" .. anus.SafeSteamID( steamid ) .. "/customperms.txt", "DATA" ) then
		perms = von.deserialize( file.Read( "anus/users/" .. anus.SafeSteamID( steamid ) .. "/customperms.txt", "DATA" ) )
	end
	
	perms[ plugin ] = false
	local target = anus.FindPlayer( steamid, "steam" )
	if target and IsValid( target ) then
		target.Perms[ plugin ] = false
		target.CustomPerms[ plugin ] = false
		
		anusSendPlayerPerms( target )
	end
	
	local customperms = anus.Users[ steamid ] and anus.Users[ steamid ].customperms or {}
	customperms[ plugin ] = false

	if anus.Users[ steamid ] then
		anus.Users[ steamid ] = { group = anus.Users[ steamid ].group, name = anus.Users[ steamid ].name, time = anus.Users[ steamid ].time, promoted_year = anus.Users[ steamid ].promoted_year, promoted_month = anus.Users[ steamid ].promoted_month, promoted_day = anus.Users[ steamid ].promoted_day, customperms = customperms }
	else
		anus.Users[ steamid ] = { group = self.UserGroup, name = steamid, customperms = customperms }
	end
	
	for k,v in next, player.GetAll() do
		if v:IsAnusSendable() then
			anusBroadcastUsers( v )
		end
	end
	
	file.Write( "anus/users/" .. anus.SafeSteamID( self:SteamID() ) .. "/customperms.txt", von.serialize( perms ) )
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

function _R.Player:HasBanHistory()	
	local history = "anus/users/" .. anus.SafeSteamID( self:SteamID() ) .. "/banhistory.txt"
	if not file.Exists( history, "DATA" ) then return false end
	
	return true
end

function _R.Player:GetBanHistory()	
	local history = "anus/users/" .. anus.SafeSteamID( self:SteamID() ) .. "/banhistory.txt"
	
	local data = von.deserialize( file.Read( history, "DATA" ) )
	return data
end
function anus.PlayerHasBanHistory( steamid )
	local history = "anus/users/" .. anus.SafeSteamID( steamid ) .. "/banhistory.txt"
	if not file.Exists( history, "DATA" ) then return false end
	
	return true
end
function anus.PlayerGetBanHistory( steamid )
	local history = "anus/users/" .. anus.SafeSteamID( steamid ) .. "/banhistory.txt"
	
	local data = von.deserialize( file.Read( history, "DATA" ) )
	return data
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
	
	local tblz = {}
	for i=48,57 do
		tblz[ i ] = string.char( i )
	end
	for i=65,90 do
		tblz[ i - 7 ] = string.char( i )
	end
	for i=97,122 do
		tblz[ i - (6 + 7) ] = string.char( i )
	end
local function CreateID()
	local id = ""
	--[[for i=1,6 do
		local rand = math.random( 1, 3 )
		rand = rand != 1 and math.random( 3, 99 ) or string.char( math.random( 97, 122 ) )
		id = id .. rand
		if i % 2 == 0 and i != 6 then
			id = id .. "-"
		end
	end]]
	--[[local reps = 8
	for i=1,reps do
		local rand = string.char( math.random( 97, 122 ) )
		id = id .. rand
		if i % 4 == 0 and i != reps then
			id = id .. "-"
		end
	end
	id = id .. "-" .. (math.random( 1, 3 ) == 1 and string.char( math.random( 65, 90 ) ) or string.char( math.random( 97, 122 ) ))
	id = id .. math.random( 100, 999 )--string.char( math.random( 97, 122 ) )]]
	
	--PrintTable( tblz )
	
	local reps = 6
	for i=1,reps do
		local rand = tblz[ math.random( 48, 109 ) ]
		--print( rand )
		id = id .. rand
		if i % 3 == 0 and i != reps then
			id = id .. "-"
		end
	end

	return id
end

function _R.Player:AssignID()
	local id = CreateID()
	self:ChatPrint( "id   " .. id .. "   " .. string.len( id ) )
end


--[[local tbl = {}
local function createidloop( i, b_tried )
	local id = CreateID()

	if tbl[ id ] and b_tried then
		print( i, id )
		return
	elseif tbl[ id ] then
		createidloop( i, true )
	end
   tbl[ id ] = true
end
	
for i=1,(6*10^5) do
  createidloop( i )
end

print( "finished" )]]