local plugin = {}
plugin.id = "mute"
plugin.chatcommand = { "!mute" }
plugin.name = "Mute"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" }
}
plugin.description = "Prevents a player from chatting"
plugin.category = "Communication"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target )
	--local exempt = {}
	for k,v in ipairs( target ) do
		--[[if not caller:isGreaterThan( v ) and caller != v then
			exempt[ #exempt + 1 ] = v
			target[ k ] = nil
			continue
		end]]

		v.AnusChatMuted = true
	end

	--if #exempt > 0 then anus.playerNotification( caller, "Couldn't mute ", exempt ) end
	--if #target == 0 then return end
	anus.notifyPlugin( caller, plugin.id, "muted ", target )
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

local plugin = {}
plugin.id = "unmute"
plugin.chatcommand = { "!unmute" }
plugin.name = "Unmute"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" }
}
plugin.optionlarguments =
{
	"Target"
}
plugin.description = "Allows a player to chat"
plugin.category = "Communication"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target )
	--local exempt = {}
	for k,v in ipairs( target ) do
		--[[if not caller:isGreaterOrEqualTo( v ) then
			exempt[ #exempt + 1 ] = v
			target[ k ] = nil
			continue
		end]]

		v.AnusChatMuted = false
	end
	
	--if #exempt > 0 then anus.playerNotification( caller, "Couldn't unmute ", exempt ) end
	--if #target == 0 then return end
	anus.notifyPlugin( caller, plugin.id, "unmuted ", target )
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

anus.registerHook( "PlayerSay", "mute", function( pl, txt, bTeamChat )
	if pl.AnusChatMuted then return "" end
end, plugin.id )