local plugin = {}
plugin.id = "rcon"
plugin.name = "RCon"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Command = "string" }
}
plugin.description = "Runs a server command, optionally outputs its results"
plugin.example = "anus rcon sv_allowcslua 1"
plugin.category = "Developer"
plugin.notarget = true
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, cmd )
	if string.sub( cmd, 1, 1 ) == " " then return end

	game.ConsoleCommand( cmd .. "\n" )
	anus.notifyPlugin( pl, plugin.id, true, color_white, "ran rcon command: ", anus.Colors.String, cmd )
	
	local args = string.Explode( " ", cmd )
	if not args[ 2 ] and cvars.String( cmd ) then
		pl:ChatPrint( "CVar " .. cmd .. " returns: " .. cvars.String( cmd ) )
	end
end
anus.registerPlugin( plugin )

local plugin = {}
plugin.id = "lua"
plugin.name = "Lua"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Lua = "string" }
}
plugin.description = "Executes a lua string on the server"
plugin.example = "anus lua ME:SetHealth( 100 )"
plugin.category = "Developer"
	-- needed if you want to do parsing like this plugin
plugin.notarget = true
plugin.noCmdMenu = true
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, lua )
	ME, THIS = pl, IsValid( pl ) and pl:GetEyeTrace().Entity or NULL
	
	local res = CompileString( lua, "[anus]", true )
	
	if not res then
		
		local code, err = pcall( res ) 
		
		if err then
			pl:ChatPrint( "Error found in code: " .. err )
		end
	
	else

		res()
		anus.notifyPlugin( pl, plugin.id, true, color_white, "ran lua code: ", anus.Colors.String, lua )
		
	end

	--ME, THIS = nil, nil
end
anus.registerPlugin( plugin )

anus.registerHook( "LuaError", "lua", function( ... )
	local args = {...}
	if string.sub( args[ 1 ], 1, 9 ) == "[anus]:1:" and IsValid( ME ) then
		ME:ChatPrint( "Error found in code: " .. args[ 1 ] )
	end
end, plugin.id )
