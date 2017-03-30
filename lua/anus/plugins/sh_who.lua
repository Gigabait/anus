local plugin = {}
plugin.id = "who"
plugin.chatcommand = { "!who" }
plugin.name = "Who"
plugin.author = "Shinycow"
plugin.description = "Prints a list of players and their usergroups"
plugin.category = "Utility"
plugin.defaultAccess = "user"

function plugin:OnRun( caller )
	local groups = {}
	for k,v in next, anus.Groups do
		groups[ k ] = {}
	end
	
	for k,v in next, player.GetAll() do
		if caller:isAnusSendable() then
			groups[ v:GetUserGroup() ][ v:Nick() ] = v:SteamID()
		else
			groups[ "user" ][ v:Nick() ] = v:SteamID()
		end
	end
	
	local group_output = {}
	for k,v in next, groups do
		group_output[ k ] = group_output[ k ] or ""
		
		for a,b in next, v do
			group_output[ k ] = group_output[ k ] .. "\t" .. a .. "\t" .. b .. "\n"
		end
	end

	caller:PrintMessage( HUD_PRINTCONSOLE, "anus who\n\n" )
	for k,v in next, group_output do
		caller:PrintMessage( HUD_PRINTCONSOLE, k .. "\n" .. v )
	end
end
anus.registerPlugin( plugin )