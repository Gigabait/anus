if SERVER then
	util.AddNetworkString( "anus_announcepanel" )
end

local plugin = {}
plugin.id = "announce"
plugin.chatcommand = { "!announce" }
plugin.name = "Announce"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" },
	{ Text = "string" },
}
plugin.description = "Blind a player with an announcement"
plugin.category = "Communication"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( caller, target, text )
	target = target[ 1 ]
	net.Start( "anus_announcepanel" )
		net.WriteString( text )
	net.Send( target )
	
	anus.serverLog( caller:Nick() .. " sent an announcement to " .. target:Nick() .. " saying: " .. text, true )
	anus.notifyPlugin( caller, plugin.id, true, "sent an announcement to ", target )
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
				local runtype = "\"" .. target:Nick() .. "\""

				pl:ConCommand( "anus " .. self.id .. " " .. runtype .. " " .. txt )
			end,
			function( txt ) 
			end
		)
	end )
end
anus.registerPlugin( plugin )



local plugin = {}
plugin.id = "announceall"
plugin.chatcommand = { "!announceall" }
plugin.name = "Announce All"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Text = "string" }
}
plugin.description = "Blind everyone with an announcement"
plugin.category = "Communication"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( caller, text )
	net.Start( "anus_announcepanel" )
		net.WriteString( text )
	net.Broadcast()
		
	anus.notifyPlugin( caller, plugin.id, true, "sent an announcement to everyone stating ", anus.Colors.String, text )
end

anus.registerPlugin( plugin )