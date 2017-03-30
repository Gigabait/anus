--ANUS_PARENTFILE = "anus/init_cl.lua"

--[[

	Groups
	
]]--
if not anus.Groups[ "user" ] then
	include( "defaultgroups.lua" )
end

function anus.getGroups()
	return anus.Groups
end

function anus.countGroupsAccess( plugin )
	local Count = 0
	local Groups = {}
	for k,v in next, anus.getGroups() do
		if v.Permissions[ plugin ] then
			Count = Count + 1
			Groups[ #Groups + 1 ] = k
		end
	end

	return Count, Groups
end

function anus.getGroupInheritance( group )
	if not group then return nil end

	return anus.getGroups()[ group ].Inheritance
end

function anus.getGroupInheritanceTree( group )
	if not group then return nil end
	if not anus.getGroups()[ group ].Inheritance then return { group } end

	local Output = {}
	Output = { group }

	local function LoopThrough( prev, inheritance )
		Output[ #Output + 1 ] = inheritance

		if anus.Groups[ inheritance ].Inheritance then
			LoopThrough( inheritance, anus.getGroups()[ inheritance ].Inheritance )
		end
	end
	LoopThrough( nil, anus.getGroups()[ group ].Inheritance )

	return Output
end

function anus.getGroupDirectInheritance( group )
	if not group then return nil end
	if not anus.getGroups()[ group ].Inheritance then return { group } end

	local Output = {}
	Output = {}

	for k,v in next, anus.getGroups() do
		if k == group then continue end

		if v.Inheritance == group then
			Output[ #Output + 1 ] = k
		end
	end

	return Output
end

function anus.groupHasInheritanceFrom( group1, group2, samegroup )
	if not group1 or not group2 then return nil end
	if group1 == group2 and not samegroup then return false end

	local tree = anus.getGroupInheritanceTree( group1 )
	for k,v in next, tree do
		if v == group2 then
			return true
		end
	end

	return false
end

local function anus_GroupsInherit()
	for k,v in next, anus.Groups do
		if not v.Inheritance then continue end

		local function LoopThrough( group, inheritance, permissions )
			for a,b in next, permissions do
				if not anus.Groups[ group ].Permissions[ a ] then
					anus.Groups[ group ].Permissions[ a ] = b
				end
			end

			if not anus.Groups[ inheritance ].Inheritance then return end

			if anus.Groups[ inheritance ].Inheritance then
				LoopThrough( group, anus.Groups[ inheritance ].Inheritance, anus.Groups[ anus.Groups[ inheritance ].Inheritance ].Permissions )
			end
		end

		LoopThrough( k, v.Inheritance, anus.Groups[ v.Inheritance ].Permissions )
	end
end
hook.Add( "Initialize", "anus_groupinheritance", anus_GroupsInherit )
hook.Add( "inherit", "fa", anus_GroupsInherit )

function anus.createGroup( id, name, inheritance, icon, color )
	if not id then return false, "Group ID must be supplied!" end
	if anus.isValidGroup( id ) then return false, "Group ID already exists!" end
	if inheritance and not anus.isValidGroup( inheritance ) then return false, "Inheritance group doesn't exist!" end

	name = name or id
	inheritance = inheritance or "user"

	local inherit = inheritance 

		-- id key is really not neccessary.
		-- remnants left over from old permission checking
		-- todo for that ^: Add function to return groups inherited from
		-- use that for every check for ids.
	anus.Groups[ id:lower() ] =
	{
	--id = math.random( 6, 99999 ),
	name = name,
	Inheritance = inherit,
	Permissions = {},
	icon = icon or "",
	color = color or Color( 125, 125, 125, 255 ),
		-- go back to later
	--isadmin = anus.Groups[ inheritance ] and anus.Groups[ inheritance ].isadmin or nil,
	--issuperadmin = anus.Groups[ inheritance ] and anus.Groups[ inheritance ].issuperadmin or nil
	}

	anus_GroupsInherit()

	return anus.Groups[ id:lower() ]
end

function anus.removeGroup( id )
	if not id then return false, "Group ID must be supplied" end
	if not anus.isValidGroup( id ) then return false, "This isn't a valid group!" end
	if anus.Groups[ id ].hardcoded then return false, "This group cannot be removed!" end
	
	for k,v in ipairs( player.GetAll() ) do
		if v:GetUserGroup() == id then
			v:SetUserGroup( "user", true )
		end
	end
	for k,v in next, anus.Users do
		if v.group == id then
			anus.Users[ k ].group = "user"
		end
	end
	
	local Inheritance = anus.Groups[ id ].Inheritance
	Inheritance = Inheritance or "user"
	for k,v in next, anus.Groups do
		if v.Inheritance and v.Inheritance == id then
			anus.Groups[ k ].Inheritance = Inheritance
		end
	end
	anus.Groups[ tostring( id ):lower() ] = nil

	anus_GroupsInherit()
	hook.Call( "anus_GroupSettingsChanged", nil, id )

	return true
end

function anus.isValidGroup( group )
	if not group or not anus.Groups[ group ] then return false end

	return true
end

net.Receive( "anus_settings_groupchanged", function()
	hook.Call( "anus_GroupSettingsChanged", nil, net.ReadString() )
end )

anus.groupPluginCache = {}
function anus.createGroupPluginCache( group, plugin )
	if not group then
		error( "No group supplied.\nThis means something somewhere messed up.." )
	end
	anus.groupPluginCache[ group ] = anus.groupPluginCache[ group ] or {}
	--anus.groupPluginCache[ group ].Permissions = anus.groupPluginCache[ group ].Permissions or {}

	anus.groupPluginCache[ group ][ plugin ] = true
end

function anus.getPlayersInGroup( group )
	local Output = {}
	if not anus.Users[ group ] then return Output end

	for k,v in next, anus.Users[ group ] do
		Output[ #Output + 1 ] = k
	end

	return Output
end

--[[

	Teams
	
]]--

anus.teamsTable = anus.teamsTable or {}

function anus.getTeams()
	return anus.teamsTable
end

function anus.setUpTeams()
	for k,v in ipairs( anus.teamsTable ) do
		team.SetUp( v.teamindex, v.name, v.color )
	end
end

net.Receive( "anus_network_teams", function()
	local Data = net.ReadTable()
	
	anus.teamsTable = Data
	anus.setUpTeams()
end )


--[[
	
	Hooks
	
]]--

anus.Hooks = {}
anus.hooksCache = {}

local AnusHooksToCache =
{
	[ "InitPostEntity" ] = true,
	[ "Initialize" ] = true,
	[ "PostGamemodeLoaded" ] = true,
}

function anus.registerHook( hookname, unique, callback, pluginid, bno_override )
	if not bno_override then
		unique = "anus_plugin_" .. pluginid .. "_" .. (unique or "")
	end

	anus.Hooks[ hookname ] = anus.Hooks[ hookname ] or {}
	anus.Hooks[ hookname ][ unique ] = { func = callback, pluginid = pluginid, active = true }

	if anus.getPlugins()[ pluginid ] and not anus.isPluginDisabled( pluginid ) then
		--print( "register hook\n" )
		--print( hookname, unique, callback )
		--print( "\n" )
		anus.getPlugins()[ pluginid ].Hooks = anus.getPlugins()[ pluginid ].Hooks or {}
		anus.getPlugins()[ pluginid ].Hooks[ hookname ] = anus.getPlugins()[ pluginid ].Hooks[ hookname ] or {}

		anus.getPlugins()[ pluginid ].Hooks[ hookname ][ unique ] = callback

		hook.Add( hookname, unique, callback )

		if AnusHooksToCache[ hookname ] then
			callback()
		end
	else
		anus.Hooks[ hookname ][ unique ].active = false
		--[[if anusHooksToCache[ hookname ] then
			anus.HooksCache[ hookname ] = {}
			anus.HooksCache[ hookname ][ unique ] = true
		end]]
	end
end

function anus.unregisterHook( hookname, unique, pluginid, bno_override )
	if not bno_override then
		unique = "anus_plugin_" .. pluginid .. "_" .. (unique or "")
	end
	hook.Remove( hookname, unique )

	if anus.Hooks[ hookname ][ unique ][ "pluginid" ] then
		anus.Hooks[ hookname ][ unique ][ "active" ] = false
	end

	if anus.getPlugins()[ pluginid ] then
		anus.getPlugins()[ pluginid ].Hooks = anus.getPlugins()[ pluginid ].Hooks or {}
		anus.getPlugins()[ pluginid ].Hooks[ hookname ] = anus.getPlugins()[ pluginid ].Hooks[ hookname ] or {}
		anus.getPlugins()[ pluginid ].Hooks[ hookname ][ unique ] = nil
	end
end

function anus.getActivePluginHooks( pluginid )
	if not anus.getPlugins()[ pluginid ] then return {} end

	local Output = {}

	for k,v in next, anus.getPlugins()[ pluginid ].Hooks or {} do
		for key,value in next, v do
			Output[ k ] = Output[ k ] or {}
			Output[ k ][ key ] = value
		end
	end

	return Output, anus.getPlugins()[ pluginid ] != nil
end

function anus.getAllPluginHooks( pluginid )
	--if not anus.getPlugins()[ pluginid ] then return nil end

	local Output = {}

	for k,v in next, anus.Hooks or {} do
		for key,value in next, v do
			if value.pluginid == pluginid then
				Output[ k ] = Output[ k ] or {}
				Output[ k ][ key ] = value.func
			end
		end
	end

	return Output, anus.getPlugins()[ pluginid ] != nil
end

--[[
	
	Plugins

]]--

anus.pluginsTable = {}
anus.unloadedPlugins = anus.unloadedPlugins or {}

if anus.loadPlugins then anus.loadPlugins() end

function anus.registerPlugin( tbl )
	if not tbl then
		Error( debug.getinfo( 1, "S" ).short_src .. " didn't supply plugin table.\n" )
		return
	end

	if anus.countGroupsAccess( tbl.id ) == 0 then
		local Group = tbl.defaultAccess

		if not anus.Groups[ Group ] then
			anus.createGroupPluginCache( Group, tbl.id )
		else
			anus.Groups[ Group ].Permissions = anus.Groups[ Group ].Permissions or {}
			anus.Groups[ Group ].Permissions[ tbl.id ] = true
		end
	end

	--[[if anus.unloadedPlugins[ tbl.id ] then
		print( "Unloaded plugin: " .. tbl.id )
		return
	end]]

	anus.getPlugins()[ tbl.id ] = anus.getPlugins()[ tbl.id ] or tbl
	anus.getPlugins()[ tbl.id ].Filename = ANUS_FILENAME or "#ERROR"
	anus.getPlugins()[ tbl.id ].FilenameStripped = ANUS_FILENAMESTRIPPED or "#ERROR"
	anus.getPlugins()[ tbl.id ].description = anus.getPlugins()[ tbl.id ].description or "No description."

	anus.getPlugins()[ tbl.id ] = anus.getPlugins()[ tbl.id ] or tbl
	local PluginData = anus.getPlugins()[ tbl.id ]
	PluginData.Filename = ANUS_FILENAME or "#ERROR"
	PluginData.FilenameStripped = ANUS_FILENAMESTRIPPED or "#ERROR"
	PluginData.description = PluginData.description or "No description."

	PluginData.argsAsString = ""
	local PluginData_OptArgCache = {}
	for k,v in next, PluginData.optionalarguments or {} do
		PluginData_OptArgCache[ v ] = true
	end
	for k,v in next, PluginData.arguments or {} do
		--[[for a,b in next, v do
			local isrequired = a == "required"
			anus.getPlugins()[ tbl.id ].argsAsString = anus.getPlugins()[ tbl.id ].argsAsString .. " " .. (isrequired and "<" or "[") .. "" .. b[ 1 ] .. ":" .. b[ 2 ] .. "" .. (isrequired and ">" or "]")
		end]]
		if not PluginData.optionalarguments or #PluginData.optionalarguments == 0 then
			for a,b in next, v do
				if not isstring( a ) then continue end

				PluginData.argsAsString = PluginData.argsAsString .. " <" .. b .. ":" .. a .. ">"
			end
		else
			for a,b in next, v do
				if not isstring( a ) then continue end
				local isrequired = PluginData_OptArgCache[ a ] == nil

				PluginData.argsAsString = PluginData.argsAsString .. " " .. (isrequired and "<" or "[") .. "" .. b .. ":" .. a .. "" .. (isrequired and ">" or "]")
			end
		end
	end

	if anus.unloadedPlugins[ tbl.id ] then
		print( "ANUS unloaded plugin: " .. tbl.id )
		anus.getPlugins()[ tbl.id ].disabled = true
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
		anus.addCommand( tbl )
	end

	--anus.pluginLoad( tbl )

	--anus.registerPluginHooks( tbl )
end

function anus.loadPlugins( dir, filename )
	if SERVER and not ANUSGROUPSLOADED then return end

	local Files, Dirs = file.Find( "anus/plugins/*.lua", "LUA" )

		-- maybe add support for loading and unloading here later
		-- still not sure if i want to support this anyways
	if not filename then

		for k,v in next, Dirs do
			local Files2,Dirs2 = file.Find( "anus/plugins/" .. v .."/*.lua", "LUA" )

			for a,b in next, Files2 do
				if b == "sh_" .. v .. ".lua" then
					ANUS_FILENAME = b:lower()
					ANUS_FILENAMESTRIPPED = string.sub( ANUS_FILENAME, 1, -(#string.GetExtensionFromFilename( ANUS_FILENAME ) + 2) )
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

	for _,v in next, Files or {} do
		ANUS_FILENAME = v:lower()
		ANUS_FILENAMESTRIPPED = string.sub( ANUS_FILENAME, 1, -(#string.GetExtensionFromFilename( ANUS_FILENAME ) + 2) )

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

function anus.getPlugins()
	return anus.pluginsTable
end

function anus.getPlugin( plugin )
	return anus.getPlugins()[ plugin ]
end

function anus.isPluginDisabled( plugin )
	return anus.getPlugins()[ plugin ] and anus.getPlugins()[ plugin ].disabled
end

function anus.pluginLoad( plugin, path )
	local Copy
	if SERVER then
		Copy = anus.unloadedPlugins[ plugin ]
		if not Copy then
			Error( "Plugin was not handling filename correctly\nPerhaps it is already enabled?\n" )
				-- why the fuck do i have to return here
			return
		end
	else
		Copy = path
	end

	if not plugin then
		error( "what is going on in base_cl.lua: " .. path .. "\n" )
	end

	anus.unloadedPlugins[ plugin ] = nil

	--anus.LoadPlugins( nil, copy )
	if not anus.getPlugins()[ plugin ].notRunnable then
		anus.addCommand( anus.getPlugins()[ plugin ] )
	end

	anus.getPlugins()[ plugin ].disabled = false

	if anus.getPlugins()[ plugin ].OnLoad then
		anus.getPlugins()[ plugin ].OnLoad()
	end

	local Tbl, Exists = anus.getAllPluginHooks( plugin )
	for k,v in next, Tbl do
		for key, value in next, v do
			anus.registerHook( k, key, value, plugin, true )
		end
	end

	if SERVER then
		anus_savePlugins()

		net.Start( "anus_plugins_receivedload" )
			net.WriteString( plugin )
			net.WriteString( Copy )
		net.Broadcast()

			-- eh
		--[[for k,v in next, player.GetAll() do
			anusSendPlayerPerms( v )
		end]]
	end

	hook.Call( "anus_PluginLoaded", nil, plugin )

	--anus.addCommand( plugin )
end

function anus.pluginUnload( plugin )
	local Tbl, Exists = anus.getActivePluginHooks( plugin )
	for k,v in next, Tbl do
		for key, value in next, v do
			anus.unregisterHook( k, key, plugin, true )
		end
	end

	if not anus.getPlugins()[ plugin ] then return false end

	local PLUGIN = plugin
	anus.unloadedPlugins[ plugin ] = anus.getPlugins()[ plugin ].Filename

	if anus.getPlugins()[ plugin ].OnUnload then
		anus.getPlugins()[ plugin ].OnUnload()
	end
 
	--anus.getPlugins()[ plugin ] = nil
	anus.removeCommand( plugin )
	--anus.getPlugins()[ plugin ] = nil
	anus.getPlugins()[ plugin ].disabled = true

	if SERVER then
		anus_savePlugins()

		net.Start( "anus_plugins_receivedunload" )
			net.WriteString( plugin )
		net.Broadcast()
	end

	hook.Call( "anus_PluginUnloaded", nil, PLUGIN )

	return true
end

function anus.registerCategory( tbl )
	if not tbl then
		Error( debug.getinfo( 1, "S" ).short_src .. " didn't supply category table.\n" )
	end

	anus.addCategory( tbl )
end

net.Receive( "anus_plugins_receivedunload", function()
	anus.pluginUnload( net.ReadString() )
end )

net.Receive( "anus_plugins_receivedload", function()
	anus.pluginLoad( net.ReadString(), net.ReadString() )
end )

--[[

CVars / Cmds

]]
anus.cvarsRegistered = anus.cvarsRegistered or {}

function anus.registerCVar( id, strdefault, strdesc )
	if not id or not isstring( id ) then
		error( "Error supplying id in anus.RegisterCVar" )
	end
	strdefault = strdefault or "0"
	strdesc = strdesc or ""
	
	anus.cvarsRegistered[ id ] = { description = strdesc, current = strdefault }
	
	CreateConVar( "anus_" .. id, strdefault, {}, strdesc )
end

net.Receive( "anus_newCVar", function()
	local cvar = net.ReadString()
	local current = net.ReadString()
	local desc = net.ReadString()

	anus.registerCVar( cvar, current, desc )
end )

net.Receive( "anus_replicateCVar", function()
	local Cvar = net.ReadString()
	local Current = net.ReadString()
	
	if not anus.cvarsRegistered[ Cvar ] then --GetConVar( Cvar ) then
		print( "convar doesnt exist..??", Cvar )
		anus.registerCVar( Cvar, Current )
	else
		anus.cvarsRegistered[ Cvar ].current = Current
		RunConsoleCommand( "anus_" .. Cvar, Current )
	end
end )


anus.accessTags = anus.accessTags or {}

net.Receive( "anus_newAccessTag", function()
	anus.accessTags[ net.ReadString() ] = net.ReadString()
end )