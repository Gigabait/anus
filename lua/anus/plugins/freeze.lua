local plugin = {}
plugin.id = "freeze"
plugin.name = "Freeze"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>"
plugin.help = "Freezes a player"
plugin.category = "Fun"
	-- chat command optional
plugin.chatcommand = "freeze"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, arg, target )
		
	if type(target) == "table" then
	
		for k,v in pairs(target) do
			if not pl:IsGreaterOrEqualTo( v ) then
				pl:ChatPrint("Sorry, you can't target " .. v:Nick())
				target[ k ] = nil
				continue
			end

			v:Lock()
			v.AnusFrozen = true
		end
		
		anus.NotifyPlugin( pl, plugin.id, "has frozen ", anus.StartPlayerList, target, anus.EndPlayerList )
	
	else
		
		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint("Sorry, you can't target " .. target:Nick())
			return
		end
		
		anus.NotifyPlugin( pl, plugin.id, "has frozen ", target )
		
		target:Lock()
		target.AnusFrozen = true
	
	end
end
local function isFrozen( pl )
	if pl.AnusFrozen then return false end
end
hook.Add( "PlayerSpawnObject", "anus_plugins_freeze", isFrozen )
hook.Add( "CanPlayerSuicide", "anus_plugins_freeze", isFrozen )
hook.Add( "PlayerDeathThink", "anus_plugins_freeze", isFrozen )
hook.Add( "DoPlayerDeath", "anus_plugins_freeze", function( pl )
	if pl:IsFrozen() then 
		pl.FreezeOldSpawn = pl:GetPos() 
		pl:UnLock()
	end
end )
hook.Add( "PlayerSpawn", "anus_plugins_freeze", function( pl )
	if pl.AnusFrozen then
		timer.CreatePlayer( pl, "FreezeRespawn", 0.1, 1, function()
			pl:Lock()
			pl:SetPos( pl.FreezeOldSpawn )
		end )
	end
end )
if not oldnumpadActivate and SERVER then
	oldnumpadActivate = numpad.Activate
	function numpad.Activate( pl, num, bIsButton )
		if pl.AnusFrozen then return end
		
		oldnumpadActivate( pl, num, bIsButton )
	end
end

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
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, arg, target )
		
	if type(target) == "table" then
	
		for k,v in pairs(target) do
			if not pl:IsGreaterOrEqualTo( v ) then
				pl:ChatPrint("Sorry, you can't target " .. v:Nick())
				target[ k ] = nil
				continue
			end
			 
			v:UnLock()
			v.AnusFrozen = false
				-- Player.UnLock ungods players.
			timer.Create("anus_plugins_unfreeze_" .. tostring(v), 0.05, 1, function()
				if IsValid(v) and v.AnusGodded then
					v:GodEnable()
				end
			end)
		end
		
		anus.NotifyPlugin( pl, plugin.id, "has unfrozen ", anus.StartPlayerList, target, anus.EndPlayerList )
	
	else
		
		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint("Sorry, you can't target " .. target:Nick())
			return
		end
		
		anus.NotifyPlugin( pl, plugin.id, "has unfrozen ", target )

		target:UnLock()
		target.AnusFrozen = false
			-- Player.UnLock ungods players.
		timer.Simple(0.1, function()
			if IsValid(target) and target.AnusGodded then
				target:GodEnable()
			end
		end)
	
	end
end
anus.RegisterPlugin( plugin )