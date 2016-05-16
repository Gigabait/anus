local plugin = {}
plugin.id = "god"
plugin.name = "God"
plugin.author = "Shinycow"
plugin.usage = "[player:Player]"
plugin.help = "Enable player's godmode"
plugin.category = "Fun"
plugin.chatcommand = "god"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, arg, target )
	for k,v in next, target do
		if not pl:IsGreaterOrEqualTo( v ) then
			pl:ChatPrint( "Sorry, you can't target " .. v:Nick() )
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
		local runtype = target:SteamID()
		if target:IsBot() then runtype = target:Nick() end

		pl:ConCommand( "anus " .. self.chatcommand .. " " .. runtype )
	end )
end
anus.RegisterPlugin( plugin )
anus.RegisterHook( "PlayerDeath", "god", function( pl )
	pl.AnusGodded = false
end, plugin.id )
anus.RegisterHook( "PlayerSpawn", "god", function( pl )
	if pl.AnusGodded then
		pl:GodEnable()
	end
end, plugin.id )



local plugin = {}
plugin.id = "ungod"
plugin.name = "Ungod"
plugin.author = "Shinycow"
plugin.usage = "[player:Player]"
plugin.help = "Disables player's godmode"
plugin.category = "Fun"
plugin.chatcommand = "ungod"

function plugin:OnRun( pl, arg, target )
	for k,v in pairs(target) do
		if not pl:IsGreaterOrEqualTo( v ) then
			pl:ChatPrint("Sorry, you can't target " .. v:Nick())
			continue
		end
			
		if not v:Alive() then continue end
			
		v.AnusGodded = false		 
		v:GodDisable()
	end

	anus.NotifyPlugin( pl, plugin.id, "disabled godmode on ", anus.StartPlayerList, target, anus.EndPlayerList )
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