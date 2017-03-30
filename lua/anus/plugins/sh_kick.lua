local plugin = {}
plugin.id = "kick"
plugin.chatcommand = { "!kick" }
plugin.name = "Kick"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" },
	{ Reason = "string", "No reason given." }
}
plugin.optionalarguments =
{
	"Reason"
}
plugin.description = "Kicks a player from the server"
plugin.example = "!kick bot Breaking server rules"
plugin.category = "Utility"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target, reason )
	--local exempt = {}
	
	for k,v in ipairs( target ) do
			-- don't kick ourselves
		--[[if not caller:isGreaterOrEqualTo( v ) or (caller == v and #target > 1) then
			exempt[ #exempt + 1  ] = v
			target[ k ] = nil
			continue
		end]]

		v:PrintMessage( HUD_PRINTCONSOLE, "------------------------" )
		v:PrintMessage( HUD_PRINTCONSOLE, "Kicked from server by " .. caller:SteamID() .. " for " .. reason )
		v:PrintMessage( HUD_PRINTCONSOLE, "------------------------" )
		timer.Create( "anus_kick_" .. tostring( v ), 0.05 * k, 1, function()
			if not IsValid( v ) then return end
			v:Kick( "Kicked (" .. reason .. ") Check console for details" )
		end )
	end
	
	--if #exempt > 0 then anus.notifyPlayer( caller, "Couldn't kick ", exempt ) end
	--if #target == 0 then return end
	anus.notifyPlugin( caller, plugin.id, "has kicked ", target, " (", anus.Colors.String, reason, ")" ) 
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
			local runtype = "\"" .. target:Nick() .. "\""

			pl:ConCommand( "anus " .. self.id .. " " .. runtype .. " " .. reasons[ i ] )
		end )
	end
	
	menu:AddOption( "Custom reason", function()
		Derma_StringRequest( 
			target:Nick(), 
			"Custom kick reason",
			"No reason given",
			function( txt )
				local runtype = "\"" .. target:Nick() .. "\""

				pl:ConCommand( "anus " .. self.id .. " " .. runtype .. " " .. txt )
			end,
			function( txt ) 
			end
		)
	end )
	
end
anus.registerPlugin( plugin )