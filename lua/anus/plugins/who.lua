local PLUGIN = {}
PLUGIN.id = "who"
PLUGIN.name = "Who"
PLUGIN.author = "Shinycow"
PLUGIN.usage = ""
PLUGIN.help = "Prints a list of players and their usergroups"
PLUGIN.category = "Utility"
PLUGIN.chatcommand = "!who"
PLUGIN.defaultAccess = "user"

function PLUGIN:OnRun( pl, arg, t, cmd )

	groups = {}
	for k,v in next, anus.Groups do
		groups[ k ] = {}
	end
	
	for k,v in next, player.GetAll() do
		groups[ v:GetUserGroup() ][ v:Nick() ] = v:SteamID()
	end
	
	PrintTable( groups )
	
	group_output = {}

	for k,v in next, groups do
		group_output[ k ] = group_output[ k ] or ""
		
		for a,b in pairs( v ) do
			group_output[ k ] = group_output[ k ] .. "\t" .. a .. "\t" .. b .. "\n"
		end
		--group_output[ k ] = group_output[ k ] .. "\t" .. v.Name .. "\t" .. (v.SteamID or "test").. "\n"
		--output = output .. v[ 1 ] .. ": " .. (plugin[ v[ 2 ] ] or "No information available") .. "\n"
	end
	
	print("\n\ntfdsf\n\n" )
	PrintTable( group_output)	
	
	local final_output = ""

	for k,v in next, group_output do
		if #v == 0 then
			final_output = final_output .. k .. "\n"
		else
			final_output = final_output .. k .. "\n\t" .. v
		end
	end
	
	print("\n\n")
	print( final_output )
	
	
	pl:PrintMessage( HUD_PRINTCONSOLE, "anus who\n\n" .. final_output )
	
	
end
anus.RegisterPlugin( PLUGIN )