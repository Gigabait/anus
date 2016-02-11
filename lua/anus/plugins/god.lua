local plugin = {}
plugin.id = "god"
plugin.name = "God"
plugin.author = "Shinycow"
plugin.usage = "[player:Player]"
plugin.help = "Toggles a player's godmode"
plugin.category = "Fun"
plugin.chatcommand = "god"
plugin.defaultAccess = GROUP_ADMIN

function plugin:OnRun( pl, arg, target )
	if not target and IsValid( pl ) then
		target = pl
	end
		
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
			
			v.AnusGodded = true
			 
			v:GodEnable()
		end
		
		anus.NotifyPlugin( pl, plugin.id, color_white, "enabled godmode on ", anus.StartPlayerList, target, anus.EndPlayerList )
	
	else
		
		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint("Sorry, you can't target " .. target:Nick())
			return
		end
		
		if not target:Alive() then pl:ChatPrint("You can't god " .. target:Nick() .. " while they're dead!") return end
		
		target.AnusGodded = true
		
		anus.NotifyPlugin( pl, plugin.id, color_white, "enabled godmode on ", team.GetColor( target:Team() ), target:Nick() )
			 
		target:GodEnable()
	
	end
end
hook.Add("PlayerDeath", "anus_plugins_god", function( pl )
	pl.AnusGodded = false
end)
hook.Add("PlayerSpawn", "anus_plugins_god", function( pl )
	if pl.AnusGodded then
		pl:GodEnable()
	end
end )
anus.RegisterPlugin( plugin )


local plugin = {}
plugin.id = "ungod"
plugin.name = "Ungod"
plugin.author = "Shinycow"
plugin.usage = "[player:Player]"
plugin.help = "Turns off a player's godmode"
plugin.category = "Fun"
plugin.chatcommand = "ungod"

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
			
			if not v:Alive() then continue end
			
			v.AnusGodded = false		 
			v:GodDisable()
		end

		anus.NotifyPlugin( pl, plugin.id, color_white, "disabled godmode on ", anus.StartPlayerList, target, anus.EndPlayerList )
	
	else
		
		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint("Sorry, you can't target " .. target:Nick())
			return
		end
		
		if not target:Alive() then pl:ChatPrint("You can't god " .. target:Nick() .. " while they're dead!") return end
		
		target.AnusGodded = false
		anus.NotifyPlugin( pl, plugin.id, color_white, "disabled godmode on ", team.GetColor( target:Team() ), target:Nick() )
			 
		target:GodDisable()
	
	end
end
anus.RegisterPlugin( plugin )