if SERVER then
	util.AddNetworkString( "anus_announcepanel" )
end

local plugin = {}
plugin.id = "announce"
plugin.name = "Announce"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>; <string:Text>"
plugin.help = "Blind a player with an announcement"
plugin.category = "Management"
	-- chat command optional
plugin.chatcommand = "announce"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, arg, target, cmd )
	local res = table.concat( arg, " " )
	
	net.Start( "anus_announcepanel" )
		net.WriteString( res )
	net.Send( target )
		
	anus.NotifyPlugin( pl, plugin.id, true, "sent an announcement to ", anus.StartPlayerList, target, anus.EndPlayerList )
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	local menu, label = parent:AddSubMenu( self.name )
	
	menu:AddOption( "Display Text", function()
		Derma_StringRequest( 
			target:Nick(), 
			"Display Text",
			"",
			function( txt )
				local runtype = target:Nick()

				pl:ConCommand( "anus " .. self.chatcommand .. " " .. runtype .. " " .. txt )
			end,
			function( txt ) 
			end
		)
	end )
end
anus.RegisterPlugin( plugin )



local plugin = {}
plugin.id = "announceall"
plugin.name = "Announce All"
plugin.author = "Shinycow"
plugin.usage = "<string:Text>"
plugin.help = "Blind everyone with an announcement"
plugin.category = "Management"
	-- chat command optional
plugin.chatcommand = "announceall"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, arg, target )
	local res = table.concat( arg, " " )
	
	net.Start( "anus_announcepanel" )
		net.WriteString( res )
	net.Broadcast()
		
	anus.NotifyPlugin( pl, plugin.id, true, "broadcasted an announcement stating ", COLOR_STRINGARGS, res )
end

anus.RegisterPlugin( plugin )