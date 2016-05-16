local plugin = {}
plugin.id = "silentnotification"
plugin.name = "Silent Notifications"
plugin.author = "Shinycow"
plugin.usage = ""
plugin.help = "Shares silent notification (e.g lua / rcon)"
plugin.example = ""
plugin.notRunnable = true
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, arg )
end

function plugin:OnLoad()
end

anus.RegisterPlugin( plugin )