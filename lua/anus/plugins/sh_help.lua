local plugin = {}

plugin.id = "help"
plugin.chatcommand = { "!help" }
plugin.name = "Help"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Command = "string" }
}
plugin.optionalarguments = 
{
	"Command"
}
plugin.description = "When all else fails"
plugin.category = "Utility"
plugin.defaultAccess = "user"

function plugin:OnRun( caller, cmd )
	if not cmd then
		local output = {}

		for k,v in next, anus.getPlugins() do
			output[ #output + 1 ] = k
		end
		table.sort( output )

		for k,v in ipairs( output ) do
			local Tabs = 2
			if #v <= 3 then Tabs = 3 end
			
			caller:PrintMessage( HUD_PRINTCONSOLE, "anus help \"" .. v .. "\"" .. string.rep( "\t", Tabs ) .. "" .. anus.getPlugin( v ).description .. "\n" )
		end

		caller:PrintMessage( HUD_PRINTCONSOLE, "\tType one of the above for more information on that plugin" )
		return
	end

	if not anus.isValidPlugin( cmd ) then return end

	local plugin = anus.getPlugins()[ cmd ]
	local calls =
	{
	{
		"Command help",
		"description",
	},
	{
		"Usage",
		"argsAsString",
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

	caller:PrintMessage( HUD_PRINTCONSOLE, "anus help \"" .. cmd .. "\"\n" .. output )
end

function plugin:GetCustomSuggestions( args ) 
	local output = {}
	if args[ 1 ] then
		for k,v in next, anus.getPlugins() do
			if not LocalPlayer():hasAccess( k ) or v.disabled then continue end
			if string.find( k, args[ 1 ] ) then
				output[ #output + 1 ] = k
			end
		end
	end

		-- outputs additional outputs
		-- second argument overrides default behavior
	return output, false
end

anus.registerPlugin( plugin )