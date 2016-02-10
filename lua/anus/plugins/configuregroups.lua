local PLUGIN = {}
PLUGIN.id = "configuregroups"
PLUGIN.name = "Configure Groups"
PLUGIN.author = "Shinycow"
PLUGIN.help = "Configure groups through the menu"
PLUGIN.notarget = true
	-- won't show up in the menu
PLUGIN.nomenu = true
PLUGIN.category = "Utility"

function PLUGIN:OnRun( pl, arg, target )
	pl:ChatPrint("Use the main menu to configure groups!")
end
anus.RegisterPlugin( PLUGIN )