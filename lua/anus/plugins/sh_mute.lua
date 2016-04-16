local plugin = {}
plugin.id = "mute"
plugin.name = "Mute"
plugin.author = "Shinycow"
plugin.usage = "[player:Player]"
plugin.help = "Prevents a player from chatting"
plugin.category = "Communication"
	-- chat command optional
plugin.chatcommand = "mute"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, args, target )
	for k,v in pairs(target) do
		if not pl:IsGreaterOrEqualTo( v ) then
			pl:ChatPrint("Sorry, you can't target " .. v:Nick())
			continue
		end

		v.AnusChatMuted = true
	end

	anus.NotifyPlugin( pl, plugin.id, "muted ", anus.StartPlayerList, target, anus.EndPlayerList )
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

local plugin = {}
plugin.id = "unmute"
plugin.name = "Unmute"
plugin.author = "Shinycow"
plugin.usage = "[player:Player]"
plugin.help = "Allows a player to chat"
plugin.category = "Communication"
	-- chat command optional
plugin.chatcommand = "unmute"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, args, target )
	for k,v in next, target do
		if not pl:IsGreaterOrEqualTo( v ) then
			pl:ChatPrint( "Sorry, you can't target " .. v:Nick() )
			continue
		end

		v.AnusChatMuted = false
	end

	anus.NotifyPlugin( pl, plugin.id, "unmuted ", anus.StartPlayerList, target, anus.EndPlayerList )
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

anus.RegisterHook( "PlayerSay", "mute", function( pl, txt, bTeamChat )
	if pl.AnusChatMuted then return "" end
end, plugin.id )