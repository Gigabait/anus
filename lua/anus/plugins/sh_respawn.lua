local plugin = {}
plugin.id = "respawn"
plugin.name = "Respawn"
plugin.author = "Shinycow"
plugin.usage = "[player:Player]"
plugin.help = "Respawns a player"
plugin.category = "Fun"
	-- chat command optional
plugin.chatcommand = "respawn"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, args, target )
	for k,v in next, target do
		if not pl:IsGreaterOrEqualTo( v ) then
			pl:ChatPrint( "Sorry, you can't target " .. v:Nick() )
			target[ k ] = nil
			continue
		end

		v:Spawn()
	end

	anus.NotifyPlugin( pl, plugin.id, "has respawned ", anus.StartPlayerList, target, anus.EndPlayerList )
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	parent:AddOption( self.name, function()
		local runtype = target:SteamID()
		if target:IsBot() then runtype = target:Nick() end

		pl:ConCommand( "anus " .. self.chatcommand .. " " .. runtype )
	end )
end
anus.RegisterPlugin( plugin )