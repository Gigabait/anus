local plugin = {}
plugin.id = "goto"
plugin.name = "Goto"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>"
plugin.help = "Teleports to a player"
plugin.category = "Teleport"
	-- chat command optional
plugin.chatcommand = "goto"
plugin.defaultAccess = GROUP_ADMIN

function plugin:OnRun( pl, args, target )
	if not IsValid( pl ) then
		pl:ChatPrint("To goto a player would cause errors, so let's not.")
		return
	end
	
	if type(target) == "table" then
		pl:ChatPrint("You can't teleport to more than one person at once!")
		return
	end
		
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
		end
	else
		pl:SetPos( pos )
	end
		
	anus.NotifyPlugin( pl, plugin.id, "teleported to ", target )
end
anus.RegisterPlugin( plugin )