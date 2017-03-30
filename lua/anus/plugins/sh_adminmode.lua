local plugin = {}
plugin.id = "adminmode"
plugin.chatcommand = { "!adminmode" }
plugin.name = "Admin Mode"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Length = "number" }
}
plugin.description = "Allow physgun/toolgun any entity for x seconds"
plugin.category = "Utility"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( caller, length )
	length = math.Clamp( length, 1, 45 )
	caller.anusAdminMode = CurTime() + length
	plugin:NotifyCallback( caller, length )
	net.Start( "anus_plugins_adminmode" )
		net.WriteUInt( length, 6 )
	net.Send( caller )

	anus.notifyPlugin( caller, plugin.id, "enabled admin mode for ", anus.Colors.String, length, " seconds" )
end

function plugin:NotifyCallback( caller, length )
	timer.createPlayer( caller, "anusNotifyAdminMode", length, 1, function()
		caller:ChatPrint( "Your admin mode has ended." )
	end )
end

anus.registerPlugin( plugin )

anus.registerHook( "PhysgunPickup", "adminmode", function( pl, ent )
	if pl.anusAdminMode and pl.anusAdminMode > CurTime() then
		if ent:IsPlayer() then
			ent.AnusOldMovetype = ent:GetMoveType()
			ent:SetMoveType( MOVETYPE_NOCLIP )
		end
		return true
	end
end, plugin.id )
anus.registerHook( "PhysgunDrop", "adminmode", function( pl, ent )
	if ent.AnusOldMovetype then
		ent:SetMoveType( ent.AnusOldMovetype )
		ent.AnusOldMovetype = nil
	end
end, plugin.id )
anus.registerHook( "CanTool", "adminmode", function( pl, tr, ent )
	if pl.anusAdminMode and pl.anusAdminMode > CurTime() then
		return true
	end
end, plugin.id )

if SERVER then
	util.AddNetworkString( "anus_plugins_adminmode" )
end

	-- fpp has no way of hooking into it afaik
if CLIENT then
	net.Receive( "anus_plugins_adminmode", function()
		local Len = net.ReadUInt( 6 )
		
		LocalPlayer().anusAdminMode = CurTime() + Len
		timer.Create( "anus_plugins_adminmodedestroy", Len, 1, function()
			LocalPlayer().anusAdminMode = nil
		end )
	end )
	
	if FPP and not oldFPPcanTouchEnt then
		oldFPPcanTouchEnt = FPP.canTouchEnt
		
		function FPP.canTouchEnt( ent, touchType )
			if LocalPlayer().anusAdminMode and LocalPlayer().anusAdminMode > CurTime() then
				return true
			end
			
			return oldFPPcanTouchEnt( ent, touchType )
		end
	end
end