local plugin = {}
plugin.id = "respawn"
plugin.name = "Respawn"
plugin.author = "Shinycow"
plugin.usage = "[player:Player]"
plugin.help = "Respawns a player"
plugin.category = "Fun"
	-- chat command optional
plugin.chatcommand = "respawn"
plugin.defaultAccess = GROUP_ADMIN

function plugin:OnRun( pl, args, target )
	if not target and IsValid( pl ) then
		target = pl
	end
	
	if type( target ) == "table" then 
		
		for k,v in pairs(target) do
			if not pl:IsGreaterOrEqualTo( v ) then
				pl:ChatPrint("Sorry, you can't target " .. v:Nick())
				target[ k ] = nil
				continue
			end
			
			--anus.NotifyPlugin( pl, plugin.id, color_white, "has respawned ", team.GetColor( v:Team() ), v:Nick() )
			v:Spawn()
		end
		
			-- new system baby
		anus.NotifyPlugin( pl, plugin.id, color_white, "has respawned ", anus.StartPlayerList, target, anus.EndPlayerList )
		
	else
	
		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint("Sorry, you can't target " .. target:Nick())
			return
		end
		
		anus.NotifyPlugin( pl, plugin.id, color_white, "has respawned ", team.GetColor( target:Team() ), target:Nick() )
		target:Spawn()
	
	end
end
anus.RegisterPlugin( plugin )