local plugin = {}
plugin.id = "me"
plugin.name = "Me"
plugin.author = "Shinycow"
plugin.usage = "[string:Text]"
plugin.help = "Me"
plugin.category = "Fun"
	-- chat command optional
plugin.chatcommand = "me"
plugin.chatcommandprefix = "/"
plugin.defaultAccess = "user"

function plugin:OnRun( pl, args, target )
	if pl.MeDelay and pl.MeDelay > CurTime() then
		pl:ChatPrint( "ME IS TIRED" )
		return
	end
	
	local str = ""
	for k,v in next, args do
		str = str .. " " .. v
	end
	
	for k,v in next, player.GetAll() do
		v:ChatPrint( "* " .. pl:Nick() .. str )
	end
	
	pl.MeDelay = CurTime() + 3
	
	return false
end

anus.RegisterPlugin( plugin )