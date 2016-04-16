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
	for k,v in pairs(target) do
		if not pl:IsGreaterOrEqualTo( v ) then
			pl:ChatPrint("Sorry, you can't target " .. v:Nick())
			target[ k ] = nil
			continue
		end

		v:Lock()
		v.AnusFrozen = true
		v:DisableSpawning()
	end
		
	anus.NotifyPlugin( pl, plugin.id, "has frozen ", anus.StartPlayerList, target, anus.EndPlayerList )
end
local function isFrozen( pl )
	if pl.AnusFrozen then return false end
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
anus.RegisterHook( "CanPlayerSuicide", "freeze", isFrozen, plugin.id )
anus.RegisterHook( "PlayerDeathThink", "freeze", isFrozen, plugin.id )
anus.RegisterHook( "DoPlayerDeath", "freeze", function( pl )
	if pl:IsFrozen() then
		pl.FreezeOldSpawn = pl:GetPos()
		pl:UnLock()
	end
end, plugin.id )
anus.RegisterHook( "PlayerSpawn", "spawnfreeze", function( pl )
	if pl.AnusFrozen and pl.FreezeOldSpawn then
		timer.CreatePlayer( pl, "FreezeRespawn", 0.1, 1, function()
			pl:Lock()
			pl:SetPos( pl.FreezeOldSpawn )
		end )
	end
end, plugin.id )


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
	for k,v in pairs(target) do
		if not pl:IsGreaterOrEqualTo( v ) then
			pl:ChatPrint("Sorry, you can't target " .. v:Nick())
			target[ k ] = nil
			continue
		end
			 
		v:UnLock()
		v.AnusFrozen = false
		v:EnableSpawning()
			-- Player.UnLock ungods players.
		timer.Create("anus_plugins_unfreeze_" .. tostring(v), 0.05, 1, function()
			if IsValid(v) and v.AnusGodded then
				v:GodEnable()
			end
		end)
	end
		
	anus.NotifyPlugin( pl, plugin.id, "has unfrozen ", anus.StartPlayerList, target, anus.EndPlayerList )
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