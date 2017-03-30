local plugin = {}
plugin.id = "arm"
plugin.chatcommand = { "!arm" }
plugin.name = "Arm"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" }
}
plugin.optionalarguments =
{
	"Target"
}
plugin.description = "Gives a player their original weapons"
plugin.category = "Fun"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target )
	--local exempt = {}
	for k,v in next, target do
		--[[if not caller:isGreaterThan( v ) or not v:Alive() and caller != v then
			exempt[ #exempt + 1 ] = v
			target[ k ] = nil
			continue
		end]]
			
		if v.OldWeapons then
			for _,b in next, v.OldWeapons do
				v:Give( b )
			end
			v.OldWeapons = nil
		else
			GAMEMODE:PlayerLoadout( v )
		end
	end
	
	--if #exempt > 0 then anus.playerNotification( caller, "Couldn't arm ", exempt ) end
	--if #target == 0 then return end
	anus.notifyPlugin( caller, plugin.id, "has armed ", target )
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	parent:AddOption( self.name, function()
		local runtype = target:Nick()

		pl:ConCommand( "anus " .. self.id .. " \"" .. runtype .. "\"" )
	end )
end
anus.registerPlugin( plugin )