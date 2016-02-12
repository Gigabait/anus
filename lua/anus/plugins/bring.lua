local plugin = {}
plugin.id = "bring"
plugin.name = "Bring"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>; [boolean:Force]"
plugin.args = {"String;false"}
plugin.help = "Brings a player to you"
plugin.category = "Teleport"
	-- chat command optional
plugin.chatcommand = "bring"

function plugin:OnRun( pl, args, target )
	if not IsValid( pl ) then
		pl:ChatPrint("To bring a player to you would cause errors, so let's not.")
		return
	end
	local force = args[1] and tobool(args[1]) or false
	
	if type(target) == "table" then
	
		local target_tele = {}
		for k,v in pairs(target) do
			if not pl:IsGreaterOrEqualTo( v ) then
				pl:ChatPrint("Sorry, you can't target " .. v:Nick())
				target[ k ] = nil
				continue
			end
			
			if pl == v then
				target[ k ] = nil
				continue
			end
			
			if not v:Alive() then
				target[ k ] = nil
				continue
			end
			
			local pos = anus.TeleportPlayer( v, pl, (force or v:GetMoveType() == "MOVETYPE_NOCLIP") )
			if pos then
				v:SetPos( pos )
				target_tele[ #target_tele + 1 ] = v
			else
					-- hey don't give up just yet!
				local pos2
				for a,b in pairs( target_tele ) do
					pos2 = anus.TeleportPlayer( v, b, (force or v:GetMoveType() == "MOVETYPE_NOCLIP") )
					if pos2 then
						v:SetPos( pos2 )
						target_tele[ #target_tele + 1 ] = v
						break
					else
							-- ok fine, give up.
						target[ k ] = nil
						break
					end
				end
			end
				
		end
		
			-- new system baby
		anus.NotifyPlugin( pl, plugin.id, color_white, "brought ", anus.StartPlayerList, target_tele, anus.EndPlayerList, color_white, " to them." )
	
	else
		
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
		
		local pos = anus.TeleportPlayer( target, pl, (force or target:GetMoveType() == "MOVETYPE_NOCLIP") )
		if not pos then pl:ChatPrint("Couldn't find a spot to put " .. target:Nick() .. " in.") return end
		
		target:SetPos( pos )
		
		anus.NotifyPlugin( pl, plugin.id, color_white, "brought ", target, color_white, " to them." )
	
	end
end
anus.RegisterPlugin( plugin )