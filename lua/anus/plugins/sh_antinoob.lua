local plugin = {}
plugin.id = "antinoob"
plugin.name = "Anti Noob"
plugin.author = "Shinycow"
plugin.description = "Stops players from spawning huge props."
plugin.example = ""
plugin.notRunnable = true
plugin.hasDataFolder = true
plugin.defaultAccess = "owner"
plugin.customData = plugin.customData or {}
plugin.customData[ "autoremove" ] = 6.9*10^6
plugin.customData[ "volumewhitelist" ] = plugin.customData[ "volumewhitelist" ] or {}
plugin.customData[ "volumewhitelist" ][ "models/props_combine/breen_tube.mdl" ] = true

function plugin:OnRun( caller )
end

local function CreateBlockedModels()
	anus_blockedmodels = {}
	
	if file.Exists( "anus/plugins/" .. plugin.id .. "/blockedmodels.txt", "DATA" ) then
		local data = file.Read( "anus/plugins/" .. plugin.id .. "/blockedmodels.txt", "DATA" )
		anus_blockedmodels = von.deserialize( data )
	end
end

function plugin:OnLoad()
	CreateBlockedModels()
end

anus.registerPlugin( plugin )

anus.registerHook( "InitPostEntity", "createblockedmodels", function()
	CreateBlockedModels()
end, plugin.id )
anus.registerHook( "PlayerSpawnProp", "checkforbigmodel", function( pl, mdl )
	if anus_blockedmodels[ mdl:lower() ] then
		pl:ChatPrint( mdl .. " is too big to spawn!" )
		return false
	end
end, plugin.id )
	-- this won't catch other methods
	-- I probably won't bother overriding cleanup.Add.
anus.registerHook( "PlayerSpawnedProp", "checkforbigmodels", function( pl, mdl, ent )
	local phys = ent:GetPhysicsObject()
	if not IsValid( phys ) then return end

	if phys:GetVolume() >= plugin.customData[ "autoremove" ] and not plugin.customData.volumewhitelist[ ent:GetModel():lower() ] then
		pl:ChatPrint( "Prop removed: It was too large" )
		anus_blockedmodels[ ent:GetModel():lower() ] = true
		ent:Remove()
		return
	end
end, plugin.id )