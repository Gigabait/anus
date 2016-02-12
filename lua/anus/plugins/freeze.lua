local plugin = {}
plugin.id = "freeze"
plugin.name = "Freeze"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>"
plugin.help = "Freezes a player"
plugin.category = "Fun"
	-- chat command optional
plugin.chatcommand = "freeze"
plugin.defaultAccess = GROUP_ADMIN

function plugin:OnRun( pl, arg, target )
		
	if type(target) == "table" then
	
		for k,v in pairs(target) do
			if not pl:IsGreaterOrEqualTo( v ) then
				pl:ChatPrint("Sorry, you can't target " .. v:Nick())
				target[ k ] = nil
				continue
			end

			v:Lock()
		end
		
		anus.NotifyPlugin( pl, plugin.id, color_white, "has frozen ", anus.StartPlayerList, target, anus.EndPlayerList )
	
	else
		
		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint("Sorry, you can't target " .. target:Nick())
			return
		end
		
		anus.NotifyPlugin( pl, plugin.id, color_white, "has frozen ", target )
		
		target:Lock()
	
	end
end
hook.Add("DoPlayerDeath", "anus_plugins_freeze", function( pl )
	if pl:IsFrozen() then
		pl.FreezeOldSpawn = pl:GetPos()
	end
end)
hook.Add("PlayerDeath", "anus_plugins_freeze", function( pl )
	if pl:IsFrozen() then
		timer.Simple(0.1, function()
			pl:Spawn()
			timer.Simple(0.1, function()
				if IsValid( pl ) and pl.FreezeOldSpawn then
					pl:SetPos( pl.FreezeOldSpawn )
				end
			end)
		end)
	end
end)
anus.RegisterPlugin( plugin )

local plugin = {}
plugin.id = "unfreeze"
plugin.name = "Unfreeze"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>"
plugin.help = "Unfreezes a player"
plugin.category = "Fun"
	-- chat command optional
plugin.chatcommand = "unfreeze"
plugin.defaultAccess = GROUP_ADMIN

function plugin:OnRun( pl, arg, target )
		
	if type(target) == "table" then
	
		for k,v in pairs(target) do
			if not pl:IsGreaterOrEqualTo( v ) then
				pl:ChatPrint("Sorry, you can't target " .. v:Nick())
				target[ k ] = nil
				continue
			end
			 
			v:UnLock()
				-- Player.UnLock ungods players.
			timer.Create("anus_plugins_unfreeze_" .. tostring(v), 0.05, 1, function()
				if IsValid(v) and v.AnusGodded then
					v:GodEnable()
				end
			end)
		end
		
		anus.NotifyPlugin( pl, plugin.id, color_white, "has unfrozen ", anus.StartPlayerList, target, anus.EndPlayerList )
	
	else
		
		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint("Sorry, you can't target " .. target:Nick())
			return
		end
		
		anus.NotifyPlugin( pl, plugin.id, color_white, "has unfrozen ", target )

		target:UnLock()
			-- Player.UnLock ungods players.
		timer.Simple(0.1, function()
			if IsValid(target) and target.AnusGodded then
				target:GodEnable()
			end
		end)
	
	end
end
anus.RegisterPlugin( plugin )