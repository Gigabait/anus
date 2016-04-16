local plugin = {}
plugin.id = "goto"
plugin.name = "Goto"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>"
plugin.help = "Teleports to a player"
plugin.category = "Teleport"
	-- chat command optional
plugin.chatcommand = "goto"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, args, target )
	if not IsValid( pl ) then
		pl:ChatPrint("To goto a player would cause errors, so let's not.")
		return
	end

	if #target > 1 then
		pl:ChatPrint("You can't teleport to more than one person at once!")
		return
	end

	target = target[ 1 ]
	
	if not pl:IsGreaterOrEqualTo( target ) then
		pl:ChatPrint("Sorry, you can't target " .. target:Nick())
		return
	end

	if pl == target then
		pl:ChatPrint("Inception is a no-no.")
		return
	end

	if not target:Alive() then
		pl:ChatPrint( target:Nick() .. " is dead!" )
		return
	end

	local pos = anus.TeleportPlayer( pl, target, pl:GetMoveType() == MOVETYPE_NOCLIP )
	if not pos then
		local Message = pl:HasAccess( "noclip" ) and "noclip has been enabled." or "turn on noclip."
		pl:ChatPrint("There wasn't a spot to put you in; " .. Message )
		
		if #Message == 24 then
			pl:SetMoveType( MOVETYPE_NOCLIP )
			pl.AnusNoclipped = true
			pl:SetPos( target:GetPos() )
		else
			return
		end
	else
		pl:SetPos( pos )
		pl:SetLocalVelocity( Vector( 0, 0, 0 ) )
	end

	anus.NotifyPlugin( pl, plugin.id, "teleported to ", target )
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