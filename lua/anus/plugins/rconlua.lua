local PLUGIN = {}
PLUGIN.id = "rcon"
PLUGIN.name = "RCon"
PLUGIN.author = "Shinycow"
PLUGIN.usage = "<string:Command>"
PLUGIN.help = "Runs a server command and optionally outputs its results"
PLUGIN.example = "!rcon sv_allowcslua 1"
PLUGIN.category = "Utility"
PLUGIN.chatcommand = "rcon"
	-- won't show who kicked the player (unless they type it in chat ha)
PLUGIN.anonymous = true
PLUGIN.defaultAccess = GROUP_SUPERADMIN

function PLUGIN:OnRun( pl, arg )
	cmd = table.concat( arg, " " )
	
	game.ConsoleCommand( cmd .. "\n" )
	
	if #arg == 1 and cvars.String( cmd ) then
		pl:ChatPrint( "CVar " .. cmd .. " returns: " .. cvars.String( cmd ) )
	end
end
anus.RegisterPlugin( PLUGIN )