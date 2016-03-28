local plugin = {}
plugin.id = "rcon"
plugin.name = "RCon"
plugin.author = "Shinycow"
plugin.usage = "<string:Command>"
plugin.help = "Runs a server command, optionally outputs its results"
plugin.example = "anus rcon sv_allowcslua 1"
plugin.category = "Development"
	-- won't show who kicked the player (unless they type it in chat ha)
plugin.anonymous = true
plugin.notarget = true
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, arg, t, cmd )
	local output = cmd

	game.ConsoleCommand( output .. "\n" )

	if #arg == 1 and cvars.String( output ) then
		pl:ChatPrint( "CVar " .. output .. " returns: " .. cvars.String( output ) )
	end
end
anus.RegisterPlugin( plugin )

local plugin = {}
plugin.id = "lua"
plugin.name = "Lua"
plugin.author = "Shinycow"
plugin.usage = "<string:Lua>"
plugin.help = "Executes a lua string on the server"
plugin.example = "anus lua ME:SetHealth( 100 )"
plugin.category = "Development"
	-- won't show who kicked the player (unless they type it in chat ha)
plugin.anonymous = true
	-- needed if you want to do parsing like this plugin
plugin.notarget = true
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, arg, t, cmd )
	ME, THIS = pl, IsValid( pl ) and pl:GetEyeTrace().Entity or NULL
	
	local res = table.concat( arg, " " )
	
	res = CompileString( res, "[anus]", true )
	
	if not res then
		
		local code, err = pcall( res ) 
		
		if err then
			pl:ChatPrint( "Error found in code: " .. err )
		else
			print( code )
		end
	
	else
		
		res()
		
	end

	ME, THIS = nil, nil
end
anus.RegisterPlugin( plugin )

