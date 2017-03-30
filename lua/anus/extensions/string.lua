function string.NiceName( input )
	if not input then return "" end
	if tonumber( input ) then return input end

	local Sub1 = string.sub( input, 1, 1 )
	local Sub2 = string.sub( input, 2, #input )

	return Sub1:upper() .. Sub2
end

function string.NiceNumber( inum, string )
	if not inum or not string then return "" end
	inum = tonumber( inum )
	if not inum then return "" end

	if inum > 1 then
		string = string .. "s"
	end

	return string
end

function string.IsSteamID( steamid )
	local Res = string.match( steamid, "STEAM_0:[0-1]:[0-9]+" )
	if not Res then return false end

	return Res
end

function string.Pluralize( input )
	if not input then return "" end
	input = tostring( input )
	
	local output = string.sub( input, #input ) == "s" and "'" or "'s"
	
	return input .. output
end