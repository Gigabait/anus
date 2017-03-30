local plugin = {}
plugin.id = "freeze"
plugin.chatcommand = { "!freeze" }
plugin.name = "Freeze"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" }
}
plugin.description = "Freezes a player"
plugin.category = "Fun"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target )
	--local exempt = {}
	for k,v in ipairs( target ) do
		--[[if not caller:isGreaterThan( v ) and caller != v and caller:GetUserGroup() != "owner" then
			exempt[ #exempt + 1 ] = v
			target[ k ] = nil
			continue
		end]]

		v:Lock()
		v.AnusFrozen = true
		v:disableSpawning()
	end
	
	--if #exempt > 0 then anus.playerNotification( caller, "Couldn't freeze ", exempt ) end
	--if #target == 0 then return end
	anus.notifyPlugin( caller, plugin.id, "has frozen ", target )
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
		local runtype = target:Nick()

		pl:ConCommand( "anus " .. self.id .. " " .. runtype )
	end )
end

anus.registerPlugin( plugin )
anus.registerHook( "CanPlayerSuicide", "freeze", isFrozen, plugin.id )
anus.registerHook( "PlayerDeathThink", "freeze", isFrozen, plugin.id )
anus.registerHook( "DoPlayerDeath", "freeze", function( pl )
	if pl:IsFrozen() then
		pl.FreezeOldSpawn = pl:GetPos()
		pl:UnLock()
	end
end, plugin.id )
anus.registerHook( "PlayerSpawn", "spawnfreeze", function( pl )
	if pl.AnusFrozen and pl.FreezeOldSpawn then
		timer.createPlayer( pl, "FreezeRespawn", 0.1, 1, function()
			pl:Lock()
			pl:SetPos( pl.FreezeOldSpawn )
		end )
	end
end, plugin.id )


local plugin = {}
plugin.id = "unfreeze"
plugin.chatcommand = { "!unfreeze" }
plugin.name = "Unfreeze"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" }
}
plugin.description = "Unfreezes a player"
plugin.category = "Fun"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target )
	--local exempt = {}
	for k,v in ipairs( target ) do
		--[[if not caller:isGreaterOrEqualTo( v ) and caller != v then
			exempt[ #exempt + 1 ] = v
			target[ k ] = nil
			continue
		end]]
			 
		v:UnLock()
		v.AnusFrozen = false
		v:enableSpawning()
			-- Player.UnLock ungods players.
		timer.Create( "anus_plugins_unfreeze_" .. tostring( v ), 0.05, 1, function()
			if IsValid(v) and v.AnusGodded then
				v:GodEnable()
			end
		end )
	end
	
	--if #exempt > 0 then anus.playerNotification( caller, "Couldn't unfreeze ", exempt ) end
	--if #target == 0 then return end
	anus.notifyPlugin( caller, plugin.id, "has unfrozen ", target )
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	parent:AddOption( self.name, function()
		local runtype = target:Nick()

		pl:ConCommand( "anus " .. self.id .. " " .. runtype )
	end )
end
anus.registerPlugin( plugin )