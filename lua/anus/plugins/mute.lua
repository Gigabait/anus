local plugin = {}
plugin.id = "mute"
plugin.name = "Mute"
plugin.author = "Shinycow"
plugin.usage = "[player:Player]"
plugin.help = "Prevents a player from chatting"
plugin.category = "Chatting"
	-- chat command optional
plugin.chatcommand = "mute"
plugin.defaultAccess = GROUP_ADMIN

function plugin:OnRun( pl, args, target )
	if not target and IsValid( pl ) then
		target = pl
	end
		
	if type(target) == "table" then
	
		for k,v in pairs(target) do
			if not pl:IsGreaterOrEqualTo( v ) then
				pl:ChatPrint("Sorry, you can't target " .. v:Nick())
				continue
			end
			
			v.AnusChatMuted = true
		end

		anus.NotifyPlugin( pl, plugin.id, color_white, "muted ", anus.StartPlayerList, target, anus.EndPlayerList )
	
	else
		
		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint("Sorry, you can't target " .. target:Nick())
			return
		end
		
		anus.NotifyPlugin( pl, plugin.id, color_white, "muted ", target )
		target.AnusChatMuted = true
	
	end
end
anus.RegisterPlugin( plugin )

local plugin = {}
plugin.id = "unmute"
plugin.name = "Unmute"
plugin.author = "Shinycow"
plugin.usage = "[player;Player]"
plugin.help = "Allows a player to chat"
plugin.category = "Chatting"
	-- chat command optional
plugin.chatcommand = "unmute"
plugin.defaultAccess = GROUP_ADMIN

function plugin:OnRun( pl, args, target )
	if not target and IsValid( pl ) then
		target = pl
	end
		
	if type(target) == "table" then
	
		for k,v in pairs(target) do
			if not pl:IsGreaterOrEqualTo( v ) then
				pl:ChatPrint("Sorry, you can't target " .. v:Nick())
				continue
			end

			v.AnusChatMuted = false
		end

		anus.NotifyPlugin( pl, plugin.id, color_white, "unmuted ", anus.StartPlayerList, target, anus.EndPlayerList )
	
	else
		
		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint("Sorry, you can't target " .. target:Nick())
			return
		end
		
		anus.NotifyPlugin( pl, plugin.id, color_white, "unmuted ", target )
		target.AnusChatMuted = false
	
	end
end
anus.RegisterPlugin( plugin )

hook.Add("PlayerSay", "anus_plugins_mute", function( pl, txt, bTeamChat )
	if pl.AnusChatMuted then return "" end
end)