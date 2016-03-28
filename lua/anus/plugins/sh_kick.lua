local plugin = {}
plugin.id = "kick"
plugin.name = "Kick"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>; [string:Reason]"
	-- String;Default reason
plugin.args = {"String;No reason given."}
plugin.help = "Kicks a player from the server"
plugin.example = "!kick bot Breaking server rules"
plugin.category = "Utility"
plugin.chatcommand = "kick"
	-- won't show who kicked the player (unless they type it in chat ha)
plugin.anonymous = true
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, arg, target )
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
		
		anus.NotifyPlugin( pl, plugin.id, "has kicked ", anus.StartPlayerList, target, anus.EndPlayerList,  " (", Color( 180, 180, 255, 255 ), reason, ")" ) 
	
	else
		
		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint("Sorry, you can't target " .. target:Nick())
			return
		end

		anus.NotifyPlugin( pl, plugin.id, "has kicked ", target, " (", Color( 180, 180, 255, 255 ), reason, ")" )
		
		target:PrintMessage( HUD_PRINTCONSOLE, "------------------------" )
		target:PrintMessage( HUD_PRINTCONSOLE, "Kicked from server by " .. pl:SteamID() .. " for " .. reason )
		target:PrintMessage( HUD_PRINTCONSOLE, "------------------------" )
		timer.Simple(0.1, function()
			if not IsValid(target) then return end
			target:Kick( "Kicked for " .. reason .. ". Check console for details" )
		end)
	
	end
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	local menu, label = parent:AddSubMenu( self.name )
	
	local reasons =
	{
	"Disrespectful",
	"Rule breaker",
	"Spamming",
	"No reason given",
	}
	
	for i=1,#reasons do
		menu:AddOption( reasons[ i ], function()
			local runtype = target:SteamID()
			if target:IsBot() then runtype = target:Nick() end

			pl:ConCommand( "anus " .. self.chatcommand .. " " .. runtype .. " " .. reasons[ i ] )
		end )
	end
	
	menu:AddOption( "Custom reason", function()
		Derma_StringRequest( 
			target:Nick(), 
			"Custom kick reason",
			"No reason given",
			function( txt )
				local runtype = target:SteamID()
				if target:IsBot() then runtype = target:Nick() end

				pl:ConCommand( "anus " .. self.chatcommand .. " " .. runtype .. " " .. txt )
			end,
			function( txt ) 
			end
		)
	end )
	
end
anus.RegisterPlugin( plugin )