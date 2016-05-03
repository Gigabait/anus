local plugin = {}
plugin.id = "who"
plugin.name = "Who"
plugin.author = "Shinycow"
plugin.usage = ""
plugin.help = "Prints a list of players and their usergroups"
plugin.category = "Utility"
plugin.chatcommand = "who"
plugin.defaultAccess = "user"

function plugin:OnRun( pl, arg, t, cmd )
	local groups = {}
	for k,v in next, anus.Groups do
		groups[ k ] = {}
	end
	
	for k,v in next, player.GetAll() do
		if pl:IsAnusSendable() then
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
	
	local final_output = ""
	for k,v in next, group_output do
		if #v == 0 then
			final_output = final_output .. k .. "\n"
		else
			final_output = final_output .. k .. "\n" .. v
		end
	end

	pl:PrintMessage( HUD_PRINTCONSOLE, "anus who\n\n" .. final_output )
end
anus.RegisterPlugin( plugin )