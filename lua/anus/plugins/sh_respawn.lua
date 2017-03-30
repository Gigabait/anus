local plugin = {}
plugin.id = "respawn"
plugin.chatcommand = { "!respawn" }
plugin.name = "Respawn"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" }
}
plugin.optionalarguments = 
{
	"Target"
}
plugin.description = "Respawns a player"
plugin.category = "Fun"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target )
	--local exempt = {}
	for k,v in ipairs( target ) do
		--[[if not caller:isGreaterOrEqualTo( v ) then
			exempt[ #exempt + 1 ] = v
			target[ k ] = nil
			continue
		end]]

		v:Spawn()
	end

	--if #exempt > 0 then anus.notifyPlayer( caller, "Couldn't respawn ", exempt ) end
	--if #target == 0 then return end
	anus.notifyPlugin( caller, plugin.id, "has respawned ", target )
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