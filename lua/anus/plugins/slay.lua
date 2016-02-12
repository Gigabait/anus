local plugin = {}
plugin.id = "slay"
plugin.name = "Slay"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>"
plugin.help = "Slays a player"
plugin.category = "Fun"
	-- chat command optional
plugin.chatcommand = "slay"
plugin.defaultAccess = GROUP_ADMIN

function plugin:OnRun( pl, arg, target )
	if type(target) == "table" then
	
		for k,v in pairs(target) do
			if not pl:IsGreaterOrEqualTo( v ) then
				pl:ChatPrint("Sorry, you can't target " .. v:Nick())
				target[ k ] = nil
				continue
			end
			
			if not v:Alive() then
				target[ k ] = nil
				continue 
			end
			
			--anus.NotifyPlugin( pl, plugin.id, color_white, "slayed ", team.GetColor( v:Team() ), v:Nick() )
			 
			v:Kill()
		end		
			-- new system baby
		anus.NotifyPlugin( pl, plugin.id, color_white, "slayed ", anus.StartPlayerList, target, anus.EndPlayerList )
	
	else
		
		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint("Sorry, you can't target " .. target:Nick())
			return
		end

		if not target:Alive() then
			pl:ChatPrint("You can't slay " .. target:Nick() .. " while they're dead!")
			return
		end
		
		anus.NotifyPlugin( pl, plugin.id, color_white, "slayed ", target )
			 
		target:Kill()
	
	end
end
anus.RegisterPlugin( plugin )