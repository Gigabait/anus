local plugin = {}
plugin.id = "hp"
plugin.name = "Health"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>; <number:hp>; [boolean:Subtract]"
plugin.args = {"Int;0;200","String;false"}
plugin.help = "Sets the health of a player"
plugin.category = "Fun"
plugin.chatcommand = "hp"
plugin.defaultAccess = GROUP_ADMIN


	-- add support for subtracting a % of their current health
function plugin:OnRun( pl, args, target )
	local subtract = args[2] and tobool(args[2]) or false
	local amt = math.Round(tonumber(args[1]))
	
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

			v:SetHealth( (subtract and v:Health() - amt or amt) )
			if v:Health() <= 0 then
				v:Kill()
			end
				
		end

		if subtract then
			anus.NotifyPlugin( pl, plugin.id, color_white, "set the health of ", anus.StartPlayerList, target, anus.EndPlayerList, color_white, " from their current to ", COlOR_STRINGARGS, amt )
		else
			anus.NotifyPlugin( pl, plugin.id, color_white, "set the health of ", anus.StartPlayerList, target, anus.EndPlayerList, color_white, " to ", COLOR_STRINGARGS, amt )
		end
	
	else
		
		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint("Sorry, you can't target " .. target:Nick())
			return
		end
		
		if not target:Alive() then
			pl:ChatPrint( target:Nick() .. " is dead!" )
			return
		end
		
		target:SetHealth( (subtract and target:Health() - amt or amt) )
		if target:Health() <= 0 then
			target:Kill()
		end
		
		if subtract then
			anus.NotifyPlugin( pl, plugin.id, color_white, "set the health of ", team.GetColor( target:Team() ), target:Nick(), color_white, " from ", COLOR_STRINGARGS, target:Health() + amt, color_white, " to ", COLOR_STRINGARGS, target:Health() )
		else
			anus.NotifyPlugin( pl, plugin.id, color_white, "set the health of ", team.GetColor( target:Team() ), target:Nick(), color_white, " to ", COLOR_STRINGARGS, amt )
		end
		
	end
end
anus.RegisterPlugin( plugin )