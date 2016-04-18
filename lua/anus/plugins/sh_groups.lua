local plugin = {}
plugin.id = "renamegroup"
plugin.name = "Rename Group"
plugin.author = "Shinycow"
plugin.usage = "<string:Group> <string:Name>"
plugin.help = "Rename a group"
plugin.category = "Groups"
	-- chat command optional
plugin.chatcommand = "renamegroup"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, arg )
	if not anus.Groups[ arg[ 1 ] ] then
		pl:ChatPrint( "\"" .. arg[ 1 ] .. "\" is not a valid group!" ) 
		return
	end
	
	local name = anus.Groups[ arg[ 1 ] ].name
	
	anus.Groups[ arg[ 1 ] ][ "name" ] = arg[ 2 ]
	anus.SaveGroups( true )
	
	anus.NotifyPlugin( pl, plugin.id, "renamed group ", COLOR_STRINGARGS, name, " to ", COLOR_STRINGARGS, arg[ 2 ] )
end

anus.RegisterPlugin( plugin )