local PLUGIN = {}
PLUGIN.id = "kick"
PLUGIN.name = "Kick"
PLUGIN.author = "Shinycow"
PLUGIN.usage = "<player:Player>; [string:Reason]"
	-- String;Default reason
PLUGIN.args = {"String;No reason given."}
PLUGIN.help = "Kicks a player from the server"
PLUGIN.example = "!kick PlayerName Breaking server rules"
PLUGIN.category = "Utility"
PLUGIN.chatcommand = "kick"
	-- won't show who kicked the player (unless they type it in chat ha)
PLUGIN.anonymous = true
PLUGIN.defaultAccess = GROUP_ADMIN

function PLUGIN:OnRun( pl, arg, target )
	local reason = "No reason given."
	
	if #arg > 0 then
		reason = table.concat( arg, " " )
	end
	
	if type(target) == "table" then
	
		for k,v in pairs(target) do
			if not pl:IsGreaterOrEqualTo( v ) then
				pl:ChatPrint("Sorry, you can't target " .. v:Nick())
				target[ k ] = nil
				continue
			end
				-- if we're kicking a table of players, lets not kick ourselves yes?
			if pl == v then
				target[ k ] = nil
				continue
			end

			v:PrintMessage( HUD_PRINTCONSOLE, "------------------------" )
			v:PrintMessage( HUD_PRINTCONSOLE, "Kicked from server by " .. pl:SteamID() .. " for " .. reason )
			v:PrintMessage( HUD_PRINTCONSOLE, "------------------------" )
			timer.Create("anus_kick_" .. tostring(v), 0.1, 1, function()
				if not IsValid(v) then return end
				v:Kick( "Kicked for " .. reason .. " Check console for details" )
			end)
		end
		
		anus.NotifyPlugin( pl, PLUGIN.id, "has kicked ", anus.StartPlayerList, target, anus.EndPlayerList,  " (", Color( 180, 180, 255, 255 ), reason, ")" ) 
	
	else
		
		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint("Sorry, you can't target " .. target:Nick())
			return
		end

		anus.NotifyPlugin( pl, PLUGIN.id, "has kicked ", target, " (", Color( 180, 180, 255, 255 ), reason, ")" )
		
		target:PrintMessage( HUD_PRINTCONSOLE, "------------------------" )
		target:PrintMessage( HUD_PRINTCONSOLE, "Kicked from server by " .. pl:SteamID() .. " for " .. reason )
		target:PrintMessage( HUD_PRINTCONSOLE, "------------------------" )
		timer.Simple(0.1, function()
			if not IsValid(target) then return end
			target:Kick( "Kicked for " .. reason .. ". Check console for details" )
		end)
	
	end
end
anus.RegisterPlugin( PLUGIN )