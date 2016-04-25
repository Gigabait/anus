function anus_giveAPIKey()
	if anus.GetPlugins()[ "altcheck" ] then
		local plugin = anus.GetPlugins()[ "altcheck" ]
		
		plugin.customData = plugin.customData or {}
		-- api keys are ~supposed~ to be private, but this has to work out-of-the-box. sorry.
		-- limited to 100k per day (across all servers running this). 
		-- If there's no response or it "doesn't work"
		-- grab your own api key at http://steamcommunity.com/dev/apikey
		plugin.customData[ "apikey" ] = "154BBB17921303177CE48CC1D1204C9D"
	end
end