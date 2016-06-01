local plugin = {}
plugin.id = "return"
plugin.name = "Return Player"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>"
plugin.help = "Returns teleported player to their previous pos"
plugin.category = "Teleport"
	-- chat command optional
plugin.chatcommand = "return"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, args, target )
	for k,v in next, target do
	
		if not pl:IsGreaterOrEqualTo( v ) then
			pl:ChatPrint("Sorry, you can't target " .. v:Nick())
			target[ k ] = nil
			continue
		end

		if not v:Alive() or not v.AnusTeleportPos then
			target[ k ] = nil
			continue
		end
		
		local pos = anus.TeleportPlayer( v, v.AnusTeleportPos, pl:GetMoveType() == MOVETYPE_NOCLIP )
		if not pos then	
			pl:ChatPrint( "Couldn't find a spot for " .. v:Nick() )
			v:SetPos( v.AnusTeleportPos )
			v:SetLocalVelocity( Vector( 0, 0, 0 ) )
			v.AnusTeleportPos = nil
		else
			v.AnusTeleportPos = nil
			v:SetPos( pos )
			v:SetLocalVelocity( Vector( 0, 0, 0 ) )
		end
		
	end

	anus.NotifyPlugin( pl, plugin.id, "returned ", anus.StartPlayerList, target, anus.EndPlayerList, " to their previous position." )
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