local plugin = {}
plugin.id = "unlimitedammo"
plugin.name = "Unlimited Ammo"
plugin.author = "Shinycow"
plugin.usage = "[player:Player]"
plugin.help = "Give me more bullets to fire"
plugin.category = "Fun"
plugin.chatcommand = "unlimitedammo"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, args, target )
	for k,v in next, target do
		if not pl:IsGreaterOrEqualTo( v ) then
			pl:ChatPrint( "Sorry, you can't target " .. v:Nick() )
			target[ k ] = nil
			continue
		end
			
		v.AnusUnlimitedAmmo = true
	end

	anus.NotifyPlugin( pl, plugin.id, "granted unlimited ammo to ", anus.StartPlayerList, target, anus.EndPlayerList )
end

anus.RegisterPlugin( plugin )

anus.RegisterHook( "EntityFireBullets", "unlimitedammo", function( ent, data )
	if ent.AnusUnlimitedAmmo and IsValid( ent:GetActiveWeapon() ) then
		local bullets = data.Num
		ent:GetActiveWeapon():SetClip1( ent:GetActiveWeapon():Clip1() + bullets )
	end
end, plugin.id )

local plugin = {}
plugin.id = "limitedammo"
plugin.name = "Limited Ammo"
plugin.author = "Shinycow"
plugin.usage = "[player:Player]"
plugin.help = "Stop with the bullets"
plugin.category = "Fun"
plugin.chatcommand = "limitedammo"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, args, target )
	for k,v in next, target do
		if not pl:IsGreaterOrEqualTo( v ) then
			pl:ChatPrint( "Sorry, you can't target " .. v:Nick() )
			target[ k ] = nil
			continue
		end
			
		v.AnusUnlimitedAmmo = false
	end

	anus.NotifyPlugin( pl, plugin.id, "revoked unlimited ammo from ", anus.StartPlayerList, target, anus.EndPlayerList )
end
anus.RegisterPlugin( plugin )