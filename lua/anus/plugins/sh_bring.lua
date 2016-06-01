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
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, args, target )
	if not IsValid( pl ) then
		pl:ChatPrint("To bring a player to you would cause errors, so let's not.")
		return
	end
	local force = args[1] and tobool(args[1]) or false
	
	if #target > 1 then
	
		local target_tele = {}
		for k,v in next, target do
			if not pl:IsGreaterOrEqualTo( v ) then
				pl:ChatPrint( "Sorry, you can't target " .. v:Nick() )
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
				v.AnusTeleportPos = v:GetPos()
				v:SetPos( pos )
				v:SetLocalVelocity( Vector( 0, 0, 0 ) )
				target_tele[ #target_tele + 1 ] = v
			else
					-- don't give up just yet!
				local pos2
				local noTele = false
				for a,b in next, target_tele do
					pos2 = anus.TeleportPlayer( v, b, ( force or v:GetMoveType() == "MOVETYPE_NOCLIP" ) )
					if pos2 then
						v.AnusTeleportPos = v:GetPos()
						v:SetPos( pos2 )
						v:SetLocalVelocity( Vector( 0, 0, 0 ) )
						target_tele[ #target_tele + 1 ] = v
						break
					end
					
						-- ok give up.
					if #target_tele == a then
						target[ k ] = nil
						break
					end
				end
				
			end
				
		end

		anus.NotifyPlugin( pl, plugin.id, "brought ", anus.StartPlayerList, target_tele, anus.EndPlayerList, " to themself." )
	
	else

		target = target[ 1 ]

		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint( "Sorry, you can't target " .. target:Nick() )
			return
		end
		
		if pl == target then
			pl:ChatPrint( "Inception is a no-no." )
			return
		end
		
		if not target:Alive() then
			pl:ChatPrint( target:Nick() .. " is dead!" )
			return
		end
		
		local pos = anus.TeleportPlayer( target, pl, (force or target:GetMoveType() == "MOVETYPE_NOCLIP") )
		if not pos then pl:ChatPrint("Couldn't find a spot to put " .. target:Nick() .. " in.") return end
		
		target.AnusTeleportPos = target:GetPos()
		target:SetPos( pos )
		target:SetLocalVelocity( Vector( 0, 0, 0 ) )
		
		anus.NotifyPlugin( pl, plugin.id, "brought ", target, " to themself." )
	
	end
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