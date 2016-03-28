local plugin = {}
plugin.id = "cleardecals"
plugin.name = "Clear Decals"
plugin.author = "Shinycow"
plugin.usage = ""
plugin.help = "Clears decals for all players"
plugin.category = "Utility"
	-- chat command optional
plugin.chatcommand = "cleardecals"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl )
	local ranOn = player.GetAll()
	
	for k,target in next, player.GetAll() do
		if not pl:IsGreaterOrEqualTo( target ) then
			ranOn[ k ] = nil
			continue
		end
			
		target:ConCommand( "r_cleardecals" )
	end
	
	anus.NotifyPlugin( pl, plugin.id, color_white, "has cleared the decals for ", anus.StartPlayerList, ranOn, anus.EndPlayerList )
end

anus.RegisterPlugin( plugin )