local plugin = {}
plugin.id = "pluginload"
plugin.name = "Load Plugin"
plugin.author = "Shinycow"
plugin.usage = "<string:plugin>"
plugin.help = "Loads and enables a previously disabled plugin"
plugin.category = "Development"
	-- chat command optional
plugin.chatcommand = "pluginload"
plugin.defaultAccess = "owner"

function plugin:OnRun( pl, arg )
	local PLUGIN = arg[ 1 ]
	if not anus.UnloadedPlugins or not anus.UnloadedPlugins[ PLUGIN ] then
		pl:ChatPrint( "Plugin \"" .. PLUGIN .. "\" was not found" )
		return
	end

	anus.PluginLoad( PLUGIN )
	anus.NotifyPlugin( pl, plugin.id, "enabled plugin ", COLOR_STRINGARGS, PLUGIN )
end
anus.RegisterPlugin( plugin )

local plugin = {}
plugin.id = "pluginunload"
plugin.name = "Unload Plugin"
plugin.author = "Shinycow"
plugin.usage = "<string:plugin>"
plugin.help = "Unloads and disables a previously enabled plugin"
plugin.category = "Development"
	-- chat command optional
plugin.chatcommand = "pluginunload"
plugin.defaultAccess = "owner"

function plugin:OnRun( pl, arg )
	local PLUGIN = arg[ 1 ]
	if not anus.GetPlugins()[ PLUGIN ] then
		pl:ChatPrint( "Plugin \"" .. PLUGIN .. "\" was not found" )
		return
	end

	anus.PluginUnload( PLUGIN )
	anus.NotifyPlugin( pl, plugin.id, "disabled plugin ", COLOR_STRINGARGS, PLUGIN )
end
anus.RegisterPlugin( plugin )