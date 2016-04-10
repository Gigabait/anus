local plugin = {}
plugin.id = "antinoob"
plugin.name = "Anti Noob"
plugin.author = "Shinycow"
plugin.usage = ""
plugin.help = "Stops players from spawning huge props."
plugin.example = ""
plugin.notRunnable = true
plugin.hasDataFolder = true
plugin.defaultAccess = "owner"
plugin.customData = plugin.customData or {}
plugin.customData[ "autoremove" ] = 5*10^6
plugin.customData[ "volumewhitelist" ] = plugin.customData[ "volumewhitelist" ] or {}
plugin.customData[ "volumewhitelist" ][ "models/props_combine/breen_tube.mdl" ] = true

function plugin:OnRun( pl, arg )
end

local function CreateBlockedModels()
	anus_blockedmodels = {}
	
	if file.Exists( "anus/plugins/" .. plugin.id .. "/blockedmodels.txt", "DATA" ) then
		anus_blockedmodels = von.deserialize( anus_blockedmodels )
	end
end

function plugin:OnLoad()
	CreateBlockedModels()
end

anus.RegisterPlugin( plugin )

anus.RegisterHook( "InitPostEntity", "createblockedmodels", function()
	CreateBlockedModels()
end, plugin.id )
anus.RegisterHook( "PlayerSpawnProp", "checkforbigmodel", function( pl, mdl )
	if anus_blockedmodels[ string.lower( mdl ) ] then
		pl:ChatPrint( mdl .. " is too big to spawn!" )
		return false
	end
end, plugin.id )
	-- this won't catch other methods
	-- I probably won't bother overriding cleanup.Add.
anus.RegisterHook( "PlayerSpawnedProp", "checkforbigmodels", function( pl, mdl, ent )
	local phys = ent:GetPhysicsObject()

	if phys:GetVolume() >= plugin.customData[ "autoremove" ] and not plugin.customData.volumewhitelist[ string.lower( ent:GetModel() ) ] then
		pl:ChatPrint( "Prop removed: It was too large" )
		anus_blockedmodels[ string.lower( ent:GetModel() ) ] = true
		ent:Remove()
		return
	end
end, plugin.id )