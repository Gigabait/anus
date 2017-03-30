local plugin = {}
plugin.id = "strip"
plugin.chatcommand = { "!strip" }
plugin.name = "Strip Weapons"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" }
}
plugin.description = "Strips a player of their weapons"
plugin.category = "Fun"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target )
	local exempt = {}
	for k,v in ipairs( target ) do
		if not caller:isGreaterOrEqualTo( v ) or not v:Alive() then
			exempt[ #exempt + 1 ] = v
			target[ k ] = nil
			continue
		end
				
		v.OldWeapons = {}
		for _,b in ipairs( v:GetWeapons() ) do
			v.OldWeapons[ #v.OldWeapons + 1 ] = b:GetClass()
		end

		v:StripWeapons()
	end

	if #exempt > 0 then anus.playerNotification( caller, "Couldn't strip the weapons of ", exempt ) end
	if #target == 0 then return end
	anus.notifyPlugin( caller, plugin.id, "stripped the weapons of ", target )
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	parent:AddOption( self.name, function()
		local runtype = "\"" .. target:Nick() .. "\""

		pl:ConCommand( "anus " .. self.id .. " " .. runtype )
	end )
end
anus.registerPlugin( plugin )
anus.registerHook( "PlayerDeath", "strip", function( pl )
	pl.OldWeapons = nil
end, plugin.id )