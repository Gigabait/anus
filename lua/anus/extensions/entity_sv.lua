	-- include this before player_sv.lua
function _R.Entity:isGreaterThan( target )
	if not IsValid( self ) then return true end
	if not anus.isValidGroup( self:GetUserGroup() ) then return false end

	if anus.groupHasInheritanceFrom( self:GetUserGroup(), target:GetUserGroup() ) then
		return true
	end

	return false
end
function _R.Entity:isEqualTo( target )
	if not IsValid( self ) then return true end
	if not anus.isValidGroup( self:GetUserGroup() ) then return false end

	if self:GetUserGroup() == target:GetUserGroup() then return true end

	return false
end
function _R.Entity:isGreaterOrEqualTo( target )
	if not IsValid( self ) then return true end
	if not anus.isValidGroup( self:GetUserGroup() ) then return false end

	if anus.groupHasInheritanceFrom( self:GetUserGroup(), target:GetUserGroup(), true ) then
		return true
	end

	return false
end
	-- todo
	-- SHINYCOW
function _R.Entity:canTargetPlayer( target, cmd )
	if not IsValid( self ) then return true end
	if not target or not cmd or not IsValid( target ) then return false end
	if not self.hasAuthenticated then return false end

	return true
end

	-- check immunity
function _R.Entity:hasAccess( plugin )
	--[[if not IsValid( self ) then return true end
	if not self.Perms then return false end
	if anus.getPlugins()[ plugin ] and anus.getPlugins()[ plugin ].noTempAccess and self:isAnusTempRank() then return false end
	if self.Perms[ plugin ] or self.Perms[ plugin:lower() ] then return true end
	if self.anusUserGroup == "owner" then return true end

	return false]]
	plugin = plugin:lower()
	
	if not IsValid( self ) then return true end
	if anus.getPlugins()[ plugin ] and anus.getPlugins()[ plugin ].noTempAccess and self:isAnusTempRank() then return false end
	if self:IsUserGroup( "owner" ) then return true end
	if self.anusPerms and self.anusPerms[ plugin ] != nil and not self.anusPerms[ plugin ] then return false end
	if self.anusPerms and self.anusPerms[ plugin ] then return true, self.anusPerms[ plugin ] end
	if not anus.Groups[ self:GetUserGroup() ].Permissions[ plugin ] then return false end

	return true
end

function _R.Entity:IsAdmin() if not IsValid(self) then return true end return false end
function _R.Entity:IsSuperAdmin() if not IsValid(self) then return true end return false end

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

function _R.Entity:isAnusTempRank()
	return anus.tempUsers[ self:SteamID() ] != nil
end

_R.Player.OldSteamIDP = _R.Player.OldSteamIDP or _R.Player.SteamID
_R.Entity.OldSteamID = _R.Entity.OldSteamID or _R.Player.SteamID 
function _R.Entity:SteamID()
	if not IsValid( self ) then return "CONSOLE" end
end

--[[if GetConVarNumber( "sv_lan" ) == 1 then
			if self == Entity(1) then
				return "STEAM_0:0:1"
			else
				return "STEAM_0:0:2"
			end
		else
			print( "wat" )
			return self:OldSteamIDP()
		end
	end
end]]

hook.Add( "InitPostEntity", "test", function()
	if GetConVarNumber( "sv_lan" ) == 1 then
		SetGlobalBool( "islan", true )
	end
end )

function _R.Player:SteamID()
	if GetConVarNumber( "sv_lan" ) == 1 then
		if self == Entity(1) then
			return "STEAM_0:0:1"
		else
			return "STEAM_0:0:2"
		end
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
hook.Add( "PostGamemodeLoaded", "anus_SteamName", function()
	if not _R.Player.SteamName then
		function _R.Entity:SteamName()
			return self:Nick()
		end
	else
		_R.Entity.OldSteamName = _R.Entity.OldSteamName or _R.Player.SteamName
		function _R.Entity:SteamName()
			if not IsValid( self ) then
				return "CONSOLE"
			else
				return self:OldSteamName()
			end
		end
	end
end )

function _R.Entity:Team()
	return 0
end

function _R.Entity:getAssignedID()
	return "x00-00x"
end