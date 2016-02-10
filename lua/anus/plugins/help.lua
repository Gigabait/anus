local plugin = {}

plugin.id = "help"
plugin.name = "Help"
plugin.author = "Shinycow"
plugin.usage = "[string:Command]"
plugin.help = "When all else fails"
plugin.category = "Utility"
	-- chat command optional
plugin.chatcommand = "help"
	-- not implemented yet. GROUP_ALL, GROUP_ADMIN, GROUP_SUPERADMIN
	-- ideas how to implement: write a file with all plugins that have perms for groups edited
	-- if not in there, use below
plugin.defaultAccess = GROUP_ALL

function plugin:OnRun( pl, arg )
	
	if not arg[ 1 ] then
		-- print all commands
		return
	end
	
	--[[PrintTable( arg )
	
	if #arg > 0 then
		
		pl:ChatPrint( #arg )
	
	end]]
	
	if anus.Plugins[ arg[ 1 ] ] then
	
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
	
end
anus.RegisterPlugin( plugin )