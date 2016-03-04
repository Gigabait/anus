local PLUGIN = {}
PLUGIN.id = "rcon"
PLUGIN.name = "RCon"
PLUGIN.author = "Shinycow"
PLUGIN.usage = "<string:Command>"
PLUGIN.help = "Runs a server command and optionally outputs its results"
PLUGIN.example = "!rcon sv_allowcslua 1"
PLUGIN.category = "Utility"
	-- won't show who kicked the player (unless they type it in chat ha)
PLUGIN.anonymous = true
PLUGIN.defaultAccess = "superadmin"

function PLUGIN:OnRun( pl, arg, t, cmd )
	local output = cmd

	game.ConsoleCommand( output .. "\n" )

	if #arg == 1 and cvars.String( output ) then
		pl:ChatPrint( "CVar " .. output .. " returns: " .. cvars.String( output ) )
	end
end
anus.RegisterPlugin( PLUGIN )

local PLUGIN = {}
PLUGIN.id = "lua"
PLUGIN.name = "Lua"
PLUGIN.author = "Shinycow"
PLUGIN.usage = "<string:Lua>"
PLUGIN.help = "Executes a lua string on the server"
PLUGIN.example = "anus lua ME:SetHealth( 100 )"
PLUGIN.category = "Utility"
	-- won't show who kicked the player (unless they type it in chat ha)
PLUGIN.anonymous = true
PLUGIN.defaultAccess = "superadmin"

function PLUGIN:OnRun( pl, arg, t, cmd )
	ME, THIS = pl, pl:GetEyeTrace().Entity
	
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
anus.RegisterPlugin( PLUGIN )

