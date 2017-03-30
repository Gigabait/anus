local plugin = {}

plugin.id = "createadvert"
plugin.name = "Create Advertisement"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Interval = "number" },
	{ Message = "string" }
}
plugin.description = "Creates a new advertisement"
plugin.category = "Utility"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( caller, interval, message )
end

anus.registerPlugin( plugin )