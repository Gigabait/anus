local plugin = {}
plugin.id = "spray"
plugin.name = "Spray"
plugin.author = "Shinycow"
plugin.usage = "[player:Player]"
plugin.help = "Turns off player spray looking capability (aka funny)"
plugin.category = "Fun"
	-- chat command optional
plugin.chatcommand = "spray"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, args, target )
	
	if type( target ) == "table" then pl:ChatPrint("Sorry you can only target one person at a time.") return end
	if not pl:IsGreaterThan( target ) then pl:ChatPrint("Insufficient access.") return end
	
	pl:ChatPrint("Turned off spraying for " .. target:Nick())
	target:SendLua([[RunConsoleCommand("cl_playerspraydisable", "1")]])

end
anus.RegisterPlugin( plugin )
		