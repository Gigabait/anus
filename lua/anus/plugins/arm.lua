local plugin = {}
plugin.id = "arm"
plugin.name = "Arm"
plugin.author = "Shinycow"
plugin.usage = "[player:Player]"
plugin.help = "Gives a player their original weapons"
plugin.category = "Fun"
	-- chat command optional
plugin.chatcommand = "arm"
plugin.defaultAccess = GROUP_ADMIN

function plugin:OnRun( pl, arg, target )
	if not target and IsValid( pl ) then
		target = pl
	end
		
	if type(target) == "table" then
	
		for k,v in pairs(target) do
			if not pl:IsGreaterOrEqualTo( v ) then
				pl:ChatPrint("Sorry, you can't target " .. v:Nick())
				continue
			end
			
			if not v:Alive() then
				target[ k ] = nil
				continue
			end
			
			--anus.NotifyPlugin( pl, plugin.id, color_white, "has armed ", team.GetColor( v:Team() ), v:Nick() )
			 
			 if v.OldWeapons then
				for _,b in pairs( v.OldWeapons ) do
					v:Give( b )
				end
			else
				GAMEMODE:PlayerLoadout( v )
			end
		end
		
		anus.NotifyPlugin( pl, plugin.id, color_white, "has armed ", anus.StartPlayerList, target, anus.EndPlayerList )
	
	else
		
		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint("Sorry, you can't target " .. target:Nick())
			return
		end
		
		if not target:Alive() then
			pl:ChatPrint( target:Nick() .. " isn't alive!" ) 
			return
		end
		
		anus.NotifyPlugin( pl, plugin.id, color_white, "has armed ", team.GetColor( target:Team() ), target:Nick() )
			
		if target.OldWeapons then
			for _,b in pairs( target.OldWeapons ) do
				target:Give( b )
			end
		else
			GAMEMODE:PlayerLoadout( target )
		end
	
	end
end
anus.RegisterPlugin( plugin )