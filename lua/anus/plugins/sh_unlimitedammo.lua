local plugin = {}
plugin.id = "unlimitedammo"
plugin.chatcommand = { "!unlimitedammo" }
plugin.name = "Unlimited Ammo"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" }
}
plugin.optionalarguments = 
{
	"Target"
}
plugin.description = "Give me more bullets to fire"
plugin.category = "Fun"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( caller, target )
	local exempt = {}
	for k,v in next, target do		
		if not caller:isGreaterOrEqualTo( v ) then
			exempt[ #exempt + 1 ] = v
			target[ k ] = nil
			continue
		end
			
		v.AnusUnlimitedAmmo = true
	end

	if #exempt > 0 then anus.playerNotification( caller, "Can't grant unlimited ammo to ", exempt ) end
	if #target == 0 then return end
	anus.notifyPlugin( caller, plugin.id, "granted unlimited ammo to ", target )
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	parent:AddOption( self.name, function()
		local runtype = target:Nick()

		pl:ConCommand( "anus " .. self.id .. " " .. runtype )
	end )
end

anus.registerPlugin( plugin )

anus.registerHook( "EntityFireBullets", "unlimitedammo", function( ent, data )
	if ent.AnusUnlimitedAmmo and IsValid( ent:GetActiveWeapon() ) then
		local bullets = data.Num
		ent:GetActiveWeapon():SetClip1( ent:GetActiveWeapon():Clip1() + bullets )
	end
end, plugin.id )

local plugin = {}
plugin.id = "limitedammo"
plugin.chatcommand = { "!limitedammo" }
plugin.name = "Limited Ammo"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" }
}
plugin.optionalarguments =
{
	"Target"
}
plugin.description = "Stop with the bullets"
plugin.category = "Fun"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( caller, target )
	local exempt = {}
	for k,v in next, target do
		if not caller:isGreaterOrEqualTo( v ) then
			exempt[ #exempt + 1 ] = v
			target[ k ] = nil
			continue
		end
			
		v.AnusUnlimitedAmmo = false
	end

	if #exempt > 0 then anus.playerNotification( caller, "Couldn't revoke unlimited ammo from ", exempt ) end
	if #target == 0 then return end
	anus.notifyPlugin( caller, plugin.id, "revoked unlimited ammo from ", target )
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	parent:AddOption( self.name, function()
		local runtype = target:Nick()

		pl:ConCommand( "anus " .. self.id .. " " .. runtype )
	end )
end

anus.registerPlugin( plugin )