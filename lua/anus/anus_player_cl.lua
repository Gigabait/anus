local _R = debug.getregistry()

_R.Player.OldAdmin = _R.Player.OldAdmin or _R.Player.IsAdmin
_R.Player.OldSuperAdmin = _R.Player.OldSuperAdmin or _R.Player.IsSuperAdmin
function _R.Player:IsAdmin()
	--return self.PlayerInfo and self.PlayerInfo["admin"] or self:OldAdmin()
	return LocalPlayer().PlayerInfo and LocalPlayer().PlayerInfo[ self ] and LocalPlayer().PlayerInfo[ self ]["admin"] or self:OldAdmin()
end
function _R.Player:IsSuperAdmin()
	--return self.PlayerInfo and self.PlayerInfo["superadmin"] or self:OldSuperAdmin()
	return LocalPlayer().PlayerInfo and LocalPlayer().PlayerInfo[ self ] and LocalPlayer().PlayerInfo[ self ]["superadmin"] or self:OldSuperAdmin()
end
_R.Player.OldIsUserGroup = _R.Player.OldIsUserGroup or _R.Player.IsUserGroup
function _R.Player:IsUserGroup( group )
	if not group then return false end
	--return self.PlayerInfo and self.PlayerInfo["group"] == group or self:OldIsUserGroup()
	return LocalPlayer().PlayerInfo and LocalPlayer().PlayerInfo[ self ] and LocalPlayer().PlayerInfo[ self ]["group"] == group or self:OldIsUserGroup()
end
_R.Player.OldGetUserGroup = _R.Player.OldGetUserGroup or _R.Player.GetUserGroup
function _R.Player:GetUserGroup()
	--return self.PlayerInfo and self.PlayerInfo["group"] or self:OldGetUserGroup()
	return LocalPlayer().PlayerInfo and LocalPlayer().PlayerInfo[ self ] and LocalPlayer().PlayerInfo[ self ]["group"] or self:OldGetUserGroup()
end

hook.Add("Initialize", "anus_sendauth", function()
		-- go ahead and block this. you won't be able to be demoted / promoted. or do anything else.
	timer.Simple(0.1, function()
		net.Start("anus_authenticate2")
		net.SendToServer()
	end)
end)

net.Receive("anus_playerperms", function()
	--[[local group = net.ReadString()
	local admin = net.ReadBit()
	local sadmin = net.ReadBit()
	
	LocalPlayer().PlayerInfo = { ["group"] = group, ["admin"] = admin, ["superadmin"] = sadmin, ["perms"] = {} }
		
	local amt = net.ReadUInt( 8 )
	for i=1,amt do
		print(i)
		LocalPlayer().PlayerInfo[ "perms" ][ net.ReadString() ] = net.ReadString()
	end]]
	
	local pl = net.ReadEntity()
	local group = net.ReadString()
	local time = net.ReadUInt( 18 )
	local admin = net.ReadBit()
	local sadmin = net.ReadBit()
	
	LocalPlayer().PlayerInfo = LocalPlayer().PlayerInfo or {}
	LocalPlayer().PlayerInfo[ pl ] = { ["group"] = group, ["time"] = time, ["admin"] = admin, ["superadmin"] = sadmin, ["perms"] = {} }
	
	local amt = net.ReadUInt( 8 )
	for i=1,amt do
		print(i)
		LocalPlayer().PlayerInfo[ pl ][ "perms" ][ net.ReadString() ] = net.ReadString()
	end
	
	if pl == LocalPlayer() and time != 0 then
		timer.Create("anus_refreshtemp", 60, time, function()
			LocalPlayer().PlayerInfo[ pl ]["time"] = LocalPlayer().PlayerInfo[ pl ]["time"] - 1
		end)
	end
	
	if pl == LocalPlayer() then
		for k,v in pairs(LocalPlayer().PlayerInfo[ LocalPlayer() ]["perms"]) do
			if not anus.Plugins[ k ] then continue end
			
			anus.AddCommand( anus.Plugins[ k ] )
		end
	end
end)