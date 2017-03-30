local plugin = {}
plugin.id = "god"
plugin.chatcommand = { "!god", "!godmode" }
plugin.name = "God"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" }
}
plugin.optionalarguments = 
{
	"Target"
}
plugin.description = "Enable player's godmode"
plugin.category = "Fun"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target )
	--local exempt = {}
	for k,v in ipairs( target ) do
		--[[if not caller:isGreaterOrEqualTo( v ) then
			exempt[ #exempt + 1 ] = v
			target[ k ] = nil
			continue
		end]]
			
		if not v:Alive() then
			target[ k ] = nil
			continue
		end
			
		v.AnusGodded = true
			 
		v:GodEnable()
	end
	
	--if #exempt > 0 then anus.playerNotification( caller, "Couldn't enable godmode for ", exempt ) end
	--if #target == 0 then return end
	anus.notifyPlugin( caller, plugin.id, "enabled godmode on ", target )
end

if SERVER then
	function plugin:OnUnload()
		for k,v in next, player.GetAll() do
			if v.AnusGodded then
				v.AnusGodded = false
				v:GodDisable()
			end
		end
	end
end
	
	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	parent:AddOption( self.name, function()
		local runtype = "\"" .. target:Nick() .. "\""

		pl:ConCommand( "anus " .. self.id .. " " .. runtype )
	end )
end
anus.registerPlugin( plugin )
anus.registerHook( "PlayerDeath", "god", function( pl )
	pl.AnusGodded = false
end, plugin.id )
anus.registerHook( "PlayerSpawn", "god", function( pl )
	if pl.AnusGodded then
		pl:GodEnable()
	end
end, plugin.id )


local plugin = {}
plugin.id = "ungod"
plugin.chatcommand = { "!ungod", "!ungodmode" }
plugin.name = "Ungod"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" }
}
plugin.optionalarguments = 
{
	"Target"
}
plugin.description = "Disables player's godmode"
plugin.category = "Fun"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target )
	--local exempt = {}
	for k,v in ipairs( target ) do	
		--[[if not caller:isGreaterOrEqualTo( v ) then
			exempt[ #exempt + 1 ] = v
			target[ k ] = nil
			continue
		end]]
			
		if not v:Alive() then continue end
			
		v.AnusGodded = false
		v:GodDisable()
	end

	--if #exempt > 0 then anus.playerNotification( caller, "Couldn't disable godmode for ", exempt ) end
	--if #target == 0 then return end
	anus.notifyPlugin( caller, plugin.id, "disabled godmode on ", target )
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	parent:AddOption( self.name, function()
		local runtype = "\"" .. target:Nick() .. "\""

		pl:ConCommand( "anus " .. self.id .. " " .. runtype )
	end )
end
anus.registerPlugin( plugin )