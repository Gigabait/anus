ANUS_RELOADALL = true     

ANUS_PARENTFILE = "base_cl.lua"
ANUS_RELOADALL = true

local plugin = {}
plugin.id = "pluginload"
plugin.chatcommand = { "!pluginload" }
plugin.name = "Load Plugin"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Plugin = "string" }
}
plugin.description = "Loads and enables a previously disabled plugin"
plugin.category = "Developer"
plugin.noCmdMenu = true
plugin.defaultAccess = "owner"

function plugin:OnRun( caller, arg )
	local PLUGIN = arg
	if not anus.unloadedPlugins or not anus.unloadedPlugins[ PLUGIN ] or PLUGIN == plugin.id then
		caller:ChatPrint( "Plugin \"" .. PLUGIN .. "\" was not found" )
		return
	end

	anus.pluginLoad( PLUGIN )
	anus.notifyPlugin( caller, plugin.id, "enabled plugin ", anus.Colors.String, PLUGIN )
end

function plugin:GetCustomSuggestions( args )
	local output = {}
	if not args[ 1 ] then
		for k,v in SortedPairs( anus.getPlugins() ) do
			output[ #output + 1 ] = k
		end
	else
		for k,v in SortedPairs( anus.getPlugins() ) do
			if string.find( k, args[ 1 ] ) and v.disabled then
				output[ #output + 1 ] = k
			end
		end
	end
	
		-- outputs additional outputs
		-- second argument overrides default behavior
	return output, false
end

anus.registerPlugin( plugin )

local plugin = {}
plugin.id = "pluginunload"
plugin.chatcommand = { "!pluginunload" } 
plugin.name = "Unload Plugin"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Plugin = "string" }
}
plugin.description = "Unloads and disables a previously enabled plugin"
plugin.category = "Developer"
plugin.noCmdMenu = true
plugin.defaultAccess = "owner"

function plugin:OnRun( caller, arg )
	local PLUGIN = arg
	if not anus.getPlugins()[ PLUGIN ] or PLUGIN == plugin.id or PLUGIN == "pluginload" then
		caller:ChatPrint( "Plugin \"" .. PLUGIN .. "\" was not found" )
		return
	end

	anus.pluginUnload( PLUGIN )
	anus.notifyPlugin( caller, plugin.id, "disabled plugin ", anus.Colors.String, PLUGIN )
end

function plugin:GetCustomSuggestions( args ) 
	local output = {}
	if not args[ 1 ] then
		for k,v in SortedPairs( anus.getPlugins() ) do
			output[ #output + 1 ] = k
		end
	else
		for k,v in SortedPairs( anus.getPlugins() ) do
			if string.find( k, args[ 1 ] ) and not v.disabled then
				output[ #output + 1 ] = k
			end
		end
	end
	
		-- outputs additional outputs
		-- second argument overrides default behavior
	return output, false
end
anus.registerPlugin( plugin )