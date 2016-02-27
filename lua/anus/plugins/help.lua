local plugin = {}

plugin.id = "help"
plugin.name = "Help"
plugin.author = "Shinycow"
plugin.usage = "[string:Command]"
plugin.help = "When all else fails"
plugin.category = "Utility"
plugin.chatcommand = "help"
plugin.defaultAccess = "user"

function plugin:OnRun( pl, arg )

	if not arg[ 1 ] then
		for k,v in pairs( anus.Plugins ) do
			pl:PrintMessage( HUD_PRINTCONSOLE, "anus help \"" .. k .. "\"\n" )
		end
		
		pl:PrintMessage( HUD_PRINTCONSOLE, "\tType one of the above for more information on that plugin" )
		
		return
	end

	if not anus.Plugins[ arg[ 1 ] ] then return end
	
	local plugin = anus.Plugins[ arg[ 1 ] ]
	local calls =
	{
	{
		"Command help",
		"help",
	},
	{
		"Usage",
		"usage",
	},
	{
		"Example",
		"example",
	}
	}
	local output = ""

	for k,v in ipairs( calls ) do
		output = output .. v[ 1 ] .. ": " .. (plugin[ v[ 2 ] ] or "No information available") .. "\n"
	end

	pl:PrintMessage( HUD_PRINTCONSOLE, "anus help \"" .. arg[ 1 ] .. "\"\n" .. output )

end
anus.RegisterPlugin( plugin )