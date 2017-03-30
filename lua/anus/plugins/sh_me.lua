local plugin = {}
plugin.id = "me"
plugin.chatcommand = { "/me" }
plugin.name = "Me"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Text = "string" }
}
plugin.description = "Me"
plugin.category = "Fun"
plugin.defaultAccess = "user"

function plugin:OnRun( caller, text )
	if caller.MeDelay and caller.MeDelay > CurTime() then
		caller:ChatPrint( string.format( "Wait %s seconds until using /me", math.Round( caller.MeDelay - CurTime(), 2 ) ) )
		return false
	end
	if caller.AnusChatMuted then return false end

	for k,v in ipairs( player.GetAll() ) do
		v:ChatPrint( "* " .. caller:Nick() .. " " .. text )
	end
	
	caller.MeDelay = CurTime() + 3
	
	return false
end

anus.registerPlugin( plugin )