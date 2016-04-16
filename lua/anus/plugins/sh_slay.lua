local plugin = {}
plugin.id = "slay"
plugin.name = "Slay"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>"
plugin.help = "Slays a player"
plugin.category = "Fun"
	-- chat command optional
plugin.chatcommand = "slay"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, arg, target )
	for k,v in next, target do
		if not pl:IsGreaterOrEqualTo( v ) then
			pl:ChatPrint( "Sorry, you can't target " .. v:Nick() )
			target[ k ] = nil
			continue
		end

		if not v:Alive() then
			target[ k ] = nil
			continue 
		end

		v:Kill()
	end	
	anus.NotifyPlugin( pl, plugin.id, "slayed ", anus.StartPlayerList, target, anus.EndPlayerList )
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