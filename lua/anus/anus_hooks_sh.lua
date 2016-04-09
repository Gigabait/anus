anus.Hooks = {}

function anus.RegisterHook( hookname, unique, callback, pluginid, bNoOverride )
	if not bNoOverride then
		unique = "anus_plugin_" .. pluginid .. "_" .. (unique or "")
	end
	
	anus.Hooks[ hookname ] = anus.Hooks[ hookname ] or {}
	anus.Hooks[ hookname ][ unique ] = { func = callback, pluginid = pluginid, active = true }
	
	if anus.GetPlugins()[ pluginid ] then 
		--print( "register hook\n" )
		--print( hookname, unique, callback )
		--print( "\n" )
		anus.GetPlugins()[ pluginid ].Hooks = anus.GetPlugins()[ pluginid ].Hooks or {}
		anus.GetPlugins()[ pluginid ].Hooks[ hookname ] = anus.GetPlugins()[ pluginid ].Hooks[ hookname ] or {}

		anus.GetPlugins()[ pluginid ].Hooks[ hookname ][ unique ] = callback
		
		hook.Add( hookname, unique, callback )
	else
		anus.Hooks[ hookname ][ unique ].active = false
	end
end

function anus.UnregisterHook( hookname, unique, pluginid, bNoOverride )
	if not bNoOverride then
		unique = "anus_plugin_" .. pluginid .. "_" .. (unique or "")
	end
	hook.Remove( hookname, unique )

	if anus.Hooks[ hookname ][ unique ][ "pluginid" ] then
		anus.Hooks[ hookname ][ unique ] = nil
	end
	
	if anus.GetPlugins()[ pluginid ] then
		anus.GetPlugins()[ pluginid ].Hooks = anus.GetPlugins()[ pluginid ].Hooks or {}
		anus.GetPlugins()[ pluginid ].Hooks[ hookname ] = anus.GetPlugins()[ pluginid ].Hooks[ hookname ] or {}
		anus.GetPlugins()[ pluginid ].Hooks[ hookname ][ unique ] = nil
	end
end

function anus.GetActivePluginHooks( pluginid )
	if not anus.GetPlugins()[ pluginid ] then return {} end
	
	local output = {}
	
	for k,v in next, anus.GetPlugins()[ pluginid ].Hooks or {} do
		for key,value in next, v do
			output[ k ] = output[ k ] or {}
			output[ k ][ key ] = value
		end
	end
	
	return output, anus.GetPlugins()[ pluginid ] != nil
end

function anus.GetAllPluginHooks( pluginid )
	--if not anus.GetPlugins()[ pluginid ] then return nil end
	
	local output = {}
	
	for k,v in next, anus.Hooks or {} do
		for key,value in next, v do
			if value.pluginid == pluginid then
				output[ k ] = output[ k ] or {}
				output[ k ][ key ] = value.func
			end
		end
	end
	
	return output, anus.GetPlugins()[ pluginid ] != nil
end
