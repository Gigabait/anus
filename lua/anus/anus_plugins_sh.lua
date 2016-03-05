anus.Plugins = {}

if anus.LoadPlugins then anus.LoadPlugins() end

function anus.RegisterPlugin( tbl )
	if not tbl then Error( debug.getinfo(1, "S").short_src .. " didn't supply table." ) return end

	anus.Plugins[ tbl.id ] = tbl
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
	 
	
	if anus.CountGroupsAccess( tbl.id ) == 0 then
		local group = tbl.defaultAccess
		if not anus.Groups[ group ] then group = "user" end

		anus.Groups[ group ].Permissions = anus.Groups[ group ].Permissions or {}
		anus.Groups[ group ].Permissions[ tbl.id ] = true
	end
	
	anus.AddCommand( tbl )
end

function anus.LoadPlugins( dir )
	if SERVER and not ANUSGROUPSLOADED then return end

	local files, dirs = file.Find( "anus/plugins/*", "LUA" )
	
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
			else
				if SERVER then
					AddCSLuaFile( "anus/plugins/" .. v .. "/" .. b )
				else
					include( "anus/plugins/" .. v .. "/" .. b )
				end
			end
		end
	end
	
	for _,v in next, files do
		ANUS_FILENAME = v:lower()
		ANUS_FILENAMESTRIPPED = string.sub( ANUS_FILENAME, 1, -(#string.GetExtensionFromFilename(ANUS_FILENAME) + 2) )
		
		include( "anus/plugins/" .. v )
		
		if SERVER then
			AddCSLuaFile( "anus/plugins/" .. v )
		end
	end
end
hook.Add( "anus_SVGroupsLoaded", "RunLoadPlugins", anus.LoadPlugins )