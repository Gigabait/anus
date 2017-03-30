	-- Monthly/Weekly/Daily
local BackupInterval = "Weekly"

	-- add support for dropbox
local plugin = {}
plugin.id = "databackup"
plugin.name = "Data Backup"
plugin.author = "Shinycow"
plugin.description = "Backs up server data"
plugin.example = ""
plugin.hasDataFolder = true
plugin.noCmdMenu = true
plugin.notRunnable = true
plugin.defaultAccess = "owner"

function plugin:OnRun( caller )
end

function plugin:BackupData()
	local groups = file.Read( "anus/" )
end

anus.registerPlugin( plugin )