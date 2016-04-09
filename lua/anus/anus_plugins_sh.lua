anus.Plugins = {}
anus.UnloadedPlugins = anus.UnloadedPlugins or {}

if anus.LoadPlugins then anus.LoadPlugins() end

function anus.RegisterPlugin( tbl )
	if not tbl then
		Error( debug.getinfo( 1, "S" ).short_src .. " didn't supply plugin table." ) 
		return
	end
	
	if anus.CountGroupsAccess( tbl.id ) == 0 then
		local group = tbl.defaultAccess
		if not anus.Groups[ group ] then group = "user" end

		anus.Groups[ group ].Permissions = anus.Groups[ group ].Permissions or {}
		anus.Groups[ group ].Permissions[ tbl.id ] = true
	end
	
	--[[if anus.UnloadedPlugins[ tbl.id ] then
		print( "Unloaded plugin: " .. tbl.id )
		return
	end]]

	anus.Plugins[ tbl.id ] = anus.Plugins[ tbl.id ] or tbl
	anus.Plugins[ tbl.id ].Filename = ANUS_FILENAME or "#ERROR"
	anus.Plugins[ tbl.id ].FilenameStripped = ANUS_FILENAMESTRIPPED or "#ERROR"
	anus.Plugins[ tbl.id ].help = anus.Plugins[ tbl.id ].help or "No help found."
	anus.Plugins[ tbl.id ].usageargs = {}
	
	local explodeusage = string.Explode( ";", anus.Plugins[ tbl.id ].usage and anus.Plugins[ tbl.id ].usage or "" )
	for k,v in next, ( explodeusage or {} ) do 
		local str = v 
		local pattern = "([%a=]+)"
		local start, endpos, word = string.find( str, pattern )

		local optional = string.sub( str, 1, 1 ) != " " and string.sub( str, 1, 1 ) or string.sub( str, 2, 2 )
		optional = optional == "[" or false

		anus.Plugins[ tbl.id ].usageargs[ #anus.Plugins[ tbl.id ].usageargs + 1 ] = {type=word, optional=optional}
	end
	
	if anus.UnloadedPlugins[ tbl.id ] then
		print( "Unloaded plugin: " .. tbl.id )
		anus.Plugins[ tbl.id ].disabled = true
		return
	end
	 
		-- moved up
	--[[if anus.CountGroupsAccess( tbl.id ) == 0 then
		local group = tbl.defaultAccess
		if not anus.Groups[ group ] then group = "user" end

		anus.Groups[ group ].Permissions = anus.Groups[ group ].Permissions or {}
		anus.Groups[ group ].Permissions[ tbl.id ] = true
	end]]

	if not tbl.notRunnable then
		anus.AddCommand( tbl )
	end
	
	--anus.PluginLoad( tbl )
	
	--anus.RegisterPluginHooks( tbl )
	
end

if CLIENT then
	function anus.RegisterCategory( tbl )
		if not tbl then
			Error( debug.getinfo( 1, "S" ).short_src .. " didn't supply category table." )
			return
		end

		anus.AddCategory( tbl )
	end
end

function anus.LoadPlugins( dir, filename )
	if SERVER and not ANUSGROUPSLOADED then return end

	local files, dirs = file.Find( "anus/plugins/*", "LUA" )
	
		-- maybe add support for loading and unloading here later
		-- still not sure if i want to support this anyways
	if not filename then
		
		for k,v in next, dirs do
			local files2,dirs2 = file.Find( "anus/plugins/" .. v .."/*", "LUA" )
			
			for a,b in next, files2 do
				if b == "sh_" .. v .. ".lua" then
					ANUS_FILENAME = b:lower()
					ANUS_FILENAMESTRIPPED = string.sub( ANUS_FILENAME, 1, -(#string.GetExtensionFromFilename(ANUS_FILENAME) + 2) )
					if SERVER then
						include( "anus/plugins/" .. v .. "/" .. b )
						AddCSLuaFile( "anus/plugins/" .. v .. "/" .. b )
					else
						include( "anus/plugins/" .. v .. "/" .. b )
					end
				elseif b == "sv_" .. v .. ".lua" then
					if SERVER then
						include( "anus/plugins/" .. v .. "/" .. b )
					else
						include( "anus/plugins/" .. v .. "/" .. b )
					end
				elseif b == "cl_" .. v .. ".lua" then
					AddCSLuaFile( "anus/plugins/" .. v .. "/" .. b )
					if CLIENT then
						include( "anus/plugins/" .. v .. "/" .. b )
					end
				else
					if SERVER then
						AddCSLuaFile( "anus/plugins/" .. v .. "/" .. b )
					else
						include( "anus/plugins/" .. v .. "/" .. b )
					end
				end
			end
		end
	end
	
	for _,v in next, files or {} do
		ANUS_FILENAME = v:lower()
		ANUS_FILENAMESTRIPPED = string.sub( ANUS_FILENAME, 1, -(#string.GetExtensionFromFilename(ANUS_FILENAME) + 2) )
		
		if filename and v == filename then
		
			if string.sub( v, 1, 3 ) == "cl_" and CLIENT then
				include( "anus/plugins/" .. v )
			elseif string.sub( v, 1, 3 ) != "cl_" then
				include( "anus/plugins/" .. v )
			end
			
			if SERVER and string.sub( v, 1, 3 ) != "sv_" then
				AddCSLuaFile( "anus/plugins/" .. v )
			end
			
		else
		
			if string.sub( v, 1, 3 ) == "cl_" and CLIENT then
				include( "anus/plugins/" .. v )
			elseif string.sub( v, 1, 3 ) != "cl_" then
				include( "anus/plugins/" .. v )
			end
			
			if SERVER and string.sub( v, 1, 3 ) != "sv_" then
				AddCSLuaFile( "anus/plugins/" .. v )
			end
		end
	end
end
hook.Add( "anus_SVGroupsLoaded", "RunLoadPlugins", anus.LoadPlugins )

function anus.GetPlugins()
	return anus.Plugins
end

if SERVER then
	util.AddNetworkString( "anus_broadcastplugins" )

	function anusBroadcastPlugins( pl )
		local output = {}
		--[[for k,v in next, anus.GetPlugins() do
			output[ k ] = 1
		end]]
		for k,v in next, anus.UnloadedPlugins or {} do
			output[ k ] = 0
		end
		
		net.Start( "anus_broadcastplugins" )
			net.WriteUInt( table.Count( output ), 8 )
			for k,v in next, output do
				net.WriteString( k )
				net.WriteBit( v == 1 and true or false )
			end
		net.Send( pl )
	end
else
	net.Receive( "anus_broadcastplugins", function()
		anus.UnloadedPlugins = anus.UnloadedPlugins or {}
	
		local count = net.ReadUInt( 8 )
		for i=1,count do
			local plugin = net.ReadString()
			anus.UnloadedPlugins[ plugin ] = net.ReadBit()
			if anus.GetPlugins()[ plugin ] then
				anus.GetPlugins()[ plugin ].disabled = true
			end
		end
	end )
end
			

	-- make this local afterwards
function anus_SavePlugins()
	local data = von.serialize( anus.UnloadedPlugins )
	
	file.Write( "anus/plugins.txt", data )
end

function anus.PluginLoad( plugin, path )
	local copy
	if SERVER then
		copy = anus.UnloadedPlugins[ plugin ]
		if not copy then
			Error( "Plugin was not handling filename correctly\nPerhaps it is already enabled?\n" ) 
				-- why the fuck do i have to return here
			return 
		end
	else
		copy = path
	end
		
	anus.UnloadedPlugins[ plugin ] = nil
	
	--anus.LoadPlugins( nil, copy )
	if not anus.GetPlugins()[ plugin ].notRunnable then
		anus.AddCommand( anus.GetPlugins()[ plugin ] )
	end
	
	anus.GetPlugins()[ plugin ].disabled = false
	
	if anus.GetPlugins()[ plugin ].OnLoad then
		anus.GetPlugins()[ plugin ].OnLoad()
	end
	
	local tbl, exists = anus.GetAllPluginHooks( plugin )
	for k,v in next, tbl do
		for key, value in next, v do
			anus.RegisterHook( k, key, value, plugin, true )
		end
	end
	
	if SERVER then
		anus_SavePlugins()
		
		net.Start( "anus_plugins_receivedload" )
			net.WriteString( plugin )
			net.WriteString( copy )
		net.Broadcast()
		
			-- eh
		for k,v in next, player.GetAll() do
			anusSendPlayerPerms( v )
		end
	end
	
	hook.Call( "anus_PluginLoaded", nil, plugin )
	
	--anus.AddCommand( plugin )
	
end

function anus.PluginUnload( plugin )
	local tbl, exists = anus.GetActivePluginHooks( plugin )
	for k,v in next, tbl do
		for key, value in next, v do
			anus.UnregisterHook( k, key, plugin, true )
		end
	end

	if not anus.GetPlugins()[ plugin ] then return false end

	local PLUGIN = plugin
	anus.UnloadedPlugins[ plugin ] = anus.GetPlugins()[ plugin ].Filename
	
	if anus.GetPlugins()[ plugin ].OnUnload then
		anus.GetPlugins()[ plugin ].OnUnload()
	end
	
	--anus.GetPlugins()[ plugin ] = nil
	anus.RemoveCommand( plugin )
	--anus.GetPlugins()[ plugin ] = nil
	anus.GetPlugins()[ plugin ].disabled = true
	
	if SERVER then
		anus_SavePlugins()
		
		net.Start( "anus_plugins_receivedunload" )
			net.WriteString( plugin )
		net.Broadcast()
	end
	
	hook.Call( "anus_PluginUnloaded", nil, PLUGIN )
	
	return true
end

if SERVER then
	--util.AddNetworkString( "anus_plugins_requestunload" )
	util.AddNetworkString( "anus_plugins_receivedunload" )
	util.AddNetworkString( "anus_plugins_receivedload" )
	
	--[[net.Receive( "anus_plugins_requestunload", function( len, pl )
		if not pl:HasAccess( "pluginunload" ) then return end
	end )]]
else
	net.Receive( "anus_plugins_receivedunload", function()
		anus.PluginUnload( net.ReadString() )
	end )
	
	net.Receive( "anus_plugins_receivedload", function()
		anus.PluginLoad( net.ReadString(), net.ReadString() )
	end )
end

if SERVER then
	hook.Add("Initialize", "anus_GrabPluginInfo", function()
		if file.Exists( "anus/plugins.txt", "DATA" ) then
			local plugins = von.deserialize( file.Read( "anus/plugins.txt", "DATA" ) )
			for k,v in next, plugins do
				if v then
					anus.UnloadedPlugins[ k ] = v
				end
			end
		end
	end)
end