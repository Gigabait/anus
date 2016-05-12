	-- todo : check for family sharing
local plugin = {}
plugin.id = "altcheck"
plugin.name = "Alt Checker"
plugin.author = "Shinycow"
plugin.usage = ""
plugin.help = "Checks player for alts on join"
plugin.example = ""
plugin.notRunnable = true
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, arg, t, cmd )
	if not plugin.customData[ "apikey" ] then
		ErrorNoHalt( "Alt checker plugin: No API key found!" )
		return
	end
	
	pl = t[ 1 ]
	
	local url = "http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key=" .. plugin.customData[ "apikey" ] .. "&steamid=" .. pl:SteamID64() .. "&appid_playing=4000&format=json"
	
	local alt = false
	
	http.Fetch( url,
		function( res )
			res = util.JSONToTable( res )
			
			if not res then
				anus.ServerLog( "No alt data found for " .. pl:SteamID() )
				return
			end
			
			local alt_steamid = res.response.lender_steamid
			
			if alt_steamid and alt_steamid != "0" then
				alt = alt_steamid
			end
		end,
		
		function( err )
			anus.ServerLog( "Alt checking: No response from server" )
		end
	)
	
	if alt then
		if anus.Bans[ util.SteamIDFrom64( alt ) ] then
			print( "printing alt from anus bans" )
			anus.ServerLog( pl:Nick() .. " (" .. pl:SteamID() .. ") is an alt of currently banned user " .. anus.Bans[ util.SteamIDFrom64( alt ) ].name .. " (" .. util.SteamIDFrom64( alt ) .. ")", true )
		else
			anus.ServerLog( pl:Nick() .. " (" .. pl:SteamID() .. ") is an alt of " .. util.SteamIDFrom64( alt ) )
		end
	else
		print( "ANUS debug: i think we checked " .. pl:Nick() )
	end
	
	for k,v in next, anus.Bans do
		if not v.ip then continue end
			
		if pl:IPAddress() == v.ip then
			anus.ServerLog( pl:Nick() .. " (" .. pl:SteamID() .. ") is an alt of currently banned user " .. v.name .. " (" .. k .. ")", true )
		end
	end
end

if SERVER then

	function plugin:OnLoad()
		anus_giveAPIKey()
	end
		
else
	
end

anus.RegisterPlugin( plugin )
if SERVER then
	anus.RegisterHook( "InitPostEntity", "altcheck", function( pl )
		anus_giveAPIKey()
	end, plugin.id )
	
	anus.RegisterHook( "PlayerInitialSpawn", "altcheck", function( pl )
		anus.GetPlugins()[ "altcheck" ].OnRun( self, NULL, nil, {pl}, nil )
	end, plugin.id )
end