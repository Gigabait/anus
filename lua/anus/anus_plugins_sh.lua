anus.Plugins = {}

if anus.LoadPlugins then anus.LoadPlugins() end

function anus.RegisterPlugin( tbl )
	if not tbl then Error( debug.getinfo(1, "S").short_src .. " didn't supply table." ) return end

	anus.Plugins[ tbl.id ] = tbl
	anus.Plugins[ tbl.id ].Filename = ANUS_FILENAME or "#ERROR"
	anus.Plugins[ tbl.id ].FilenameStripped = ANUS_FILENAMESTRIPPED or "#ERROR"

	anus.AddCommand( tbl )
end

function anus.LoadPlugins( dir )
	local files, dirs = file.Find("anus/plugins/*", "LUA")
	
	for k,v in pairs(dirs) do
		local files2,dirs2 = file.Find("anus/plugins/" .. v .."/*", "LUA")
		
		for a,b in pairs(files2) do
			if b == "sh_" .. v .. ".lua" then
				ANUS_FILENAME = b:lower()
				ANUS_FILENAMESTRIPPED = string.sub(ANUS_FILENAME, 1, -(#string.GetExtensionFromFilename(ANUS_FILENAME) + 2))
				if SERVER then
					include("anus/plugins/" .. v .. "/" .. b)
					AddCSLuaFile("anus/plugins/" .. v .. "/" .. b)
				else
					include("anus/plugins/" .. v .. "/" .. b)
				end
			elseif b == "sv_" .. v .. ".lua" then
				if SERVER then
					include("anus/plugins/" .. v .. "/" .. b)
				else
					include("anus/plugins/" .. v .. "/" .. b)
				end
			else
				if SERVER then
					AddCSLuaFile("anus/plugins/" .. v .. "/" .. b)
				else
					include("anus/plugins/" .. v .. "/" .. b)
				end
			end
		end
	end
	
	for _,v in pairs(files) do
		ANUS_FILENAME = v:lower()
		ANUS_FILENAMESTRIPPED = string.sub(ANUS_FILENAME, 1, -(#string.GetExtensionFromFilename(ANUS_FILENAME) + 2))
		
		include("anus/plugins/" .. v)
		
		if SERVER then
			AddCSLuaFile("anus/plugins/" .. v)
		end
	end
end