local plugin = {}
plugin.id = "asay"
plugin.chatcommand = { "!asay", "@" }
plugin.name = "Admin Chat"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Message = "string" }
}
plugin.description = "Sends a message to all admins online"
plugin.category = "Communication"
plugin.defaultAccess = "user"

function plugin:OnRun( caller, message )
		-- SHINYCOW: player has to be gagged + muted?
	if caller.AnusChatMuted then return false end
	
	for k,v in ipairs( player.GetAll() ) do
		if v:IsAdmin() or v == caller then
			anus.playerNotification( v, Color( 255, 0, 0, 255 ), "(TO ADMINS) ", caller, ": ", anus.Colors.String, message )
		end
	end
	anus.serverLog( caller:Nick() .. " sent to admins: " .. message )
	
	return false
end
anus.registerPlugin( plugin )