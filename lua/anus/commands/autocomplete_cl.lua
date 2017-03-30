ANUS_PARENTFILE = "anus/commands/consolecommands_sh.lua"

function anus_AutoComplete( cmd, args )
	local Output = {}
	local ArgTbl = {}
	local StringStartPos = nil
	for i=1,#args do
		if not StringStartPos then
			if args[ i ] != " " and args[ i ] == "\"" then
				if args[ i - 1 ] == " " then
					ArgTbl[ #ArgTbl ] = "\""
				else
					ArgTbl[ #ArgTbl + 1 ] = "\""
				end
				StringStartPos = i
			elseif args[ i ] == " " and args[ i - 1 ] != " " then
				ArgTbl[ #ArgTbl + 1 ] = ""
			elseif args[ i ] != " " then
				ArgTbl[ #ArgTbl ] = ArgTbl[ #ArgTbl ] .. args[ i ]
			end
		else
			if args[ i ] == "\"" then
				ArgTbl[ #ArgTbl ] = ArgTbl[ #ArgTbl ] .. "\""
				StringStartPos = nil
			else
				ArgTbl[ #ArgTbl ] = ArgTbl[ #ArgTbl ] .. args[ i ]
			end
		end
	end

	LocalPlayer().anus_AutoComplete_suggestions = LocalPlayer().anus_AutoComplete_suggestions or {}

	local Access = {}
	if #args == 1 then
		for k,v in next, anus.getPlugins() do
			if anus.isPluginDisabled( k ) then continue end
			if not LocalPlayer():hasAccess( k ) then continue end
			if v.notRunnable then continue end

			Access[ k ] = true
			Output[ #Output + 1 ] = "anus " .. k
		end

		LocalPlayer().anus_AutoComplete_access = Access

		return Output
	end

	local Plugin = ArgTbl[ 1 ]:lower()
	if anus.getPlugins()[ Plugin ] then
		Output[ #Output + 1 ] = "anus " .. Plugin .. " " .. anus.getPlugins()[ Plugin ].argsAsString

		table.remove( ArgTbl, 1 )

		local suggestions, override = nil, nil
		if anus.getPlugins()[ Plugin ].GetCustomSuggestions != nil then
			suggestions, override = anus.getPlugins()[ Plugin ]:GetCustomSuggestions( ArgTbl )
		end

		if suggestions != nil then
			for k,v in ipairs( suggestions ) do
				Output[ #Output + 1 ] = "anus " .. Plugin .. " " .. v
			end
		end

		if override == nil or override == false then
			for k,v in next, anus.getPlugins()[ Plugin ].arguments or {} do
				for a,b in next, v do
					if b == "player" then
						if ArgTbl[ k ] then
							for _,ply in ipairs( player.GetAll() ) do
								if string.find( ply:Nick():lower(), ArgTbl[ k ], nil, true ) then
									Output[ #Output + 1 ] = "anus " .. Plugin .. " \"" .. ply:Nick() .. "\""
								end
							end
						else
							for _,ply in ipairs( player.GetAll() ) do
								Output[ #Output + 1 ] = "anus " .. Plugin .. " \"" .. ply:Nick() .. "\""
							end
						end
					end
				end
			end
		end

	else
		for k,v in next, LocalPlayer().anus_AutoComplete_access or {} do
			if string.find( k, Plugin, nil, true ) then
				Output[ #Output + 1 ] = "anus " .. k
			end
		end
	end

	LocalPlayer().anus_AutoComplete_suggestions = ArgTbl

	return Output
end