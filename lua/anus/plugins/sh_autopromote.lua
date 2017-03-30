local _R = debug.getregistry()
function _R.Player:setTotalTimePlayed( num )
	self:SetNW2Int( "anus_TotalTime", num )
end
function _R.Player:addTotalTimePlayed( num )
	self:setTotalTimePlayed( self:getTotalTimePlayed() + num )
end
function _R.Player:getTotalTimePlayed()
	return self:GetNW2Int( "anus_TotalTime", 0 ) + self:getSessionTimePlayed()
end
function _R.Player:setSessionTimePlayed( num ) 
	self.SessionJoinTime = CurTime() - num
end
function _R.Player:addSessionTimePlayed( num )
	self:setSessionTimePlayed( self:getSessionTimePlayed() + num )
end
function _R.Player:getSessionTimePlayed()
	return CurTime() - ( self.SessionJoinTime or CurTime() )
end

local plugin = {}
plugin.id = "playertime"
plugin.name = "Player Time"
plugin.author = "Shinycow"
plugin.description = "Keeps track of player activity"
plugin.example = ""
plugin.notRunnable = true
plugin.hasDataFolder = true
plugin.category = "Time"
plugin.defaultAccess = "owner"

function plugin:SavePlayer( pl )
	local dir = "anus/plugins/" .. self.id .. "/" .. anus.safeSteamID( pl ) .. ".txt"
	local data = { total = pl:getTotalTimePlayed(), lastonline = os.time(), lastsession = pl:getSessionTimePlayed() }
	
	file.Write( dir, von.serialize( data ) )
end

function plugin:NewPlayer( pl )
	pl:setTotalTimePlayed( pl:getSessionTimePlayed() )
	
	self:SavePlayer( pl )
end

function plugin:LoadPlayerTime( pl )
	local dir = "anus/plugins/" .. self.id .. "/" .. anus.safeSteamID( pl ) .. ".txt"
	
	pl.SessionJoinTime = CurTime()
	pl:setSessionTimePlayed( 0 )
	
	if file.Exists( dir, "DATA" ) then
		local data = von.deserialize( file.Read( dir, "DATA" ) )
		pl:setTotalTimePlayed( data.total )
		
		return true, data
	else
		self:NewPlayer( pl )
		return false
	end
end
	
anus.registerPlugin( plugin )

if SERVER then
	anus.registerHook( "PlayerInitialSpawn", "playertime", function( pl )
		local returning, data = plugin:LoadPlayerTime( pl )
		
		if returning then
			anus.playerNotification( nil, pl, " was last seen on ", anus.Colors.String, os.date( "%a, %b %d, %Y at %H:%M:%S", data.lastonline ) )
		else
			anus.playerNotification( nil, "Welcome to the server, ", pl )
		end
		
		timer.createPlayer( pl, "playertime", 180, 0, function()
			plugin:SavePlayer( pl )
		end )
	end, plugin.id )

	anus.registerHook( "player_disconnect", "playertime", function( data )
		local pl = Player( data.userid )
		if not pl.HasAuthed then return end
		
		plugin:SavePlayer( pl )
	end, plugin.id )
else
	anus.registerHook( "InitPostEntity", "playertime", function()
		LocalPlayer().SessionJoinTime = CurTime()
	end, plugin.id )
end


if SERVER then
	anus.registerAccessTag( "modifyautopromotion", "owner", "Allows this group to change auto promote settings" )
end

local plugin = {}
plugin.id = "autopromote"
plugin.name = "Auto Promote"
plugin.author = "Shinycow"
plugin.description = "Promotes players based on their time played"
plugin.example = ""
plugin.notRunnable = true
plugin.hasDataFolder = true
plugin.category = "Time"
plugin.defaultAccess = "owner"

local function SaveAutoPromote()
	file.Write( "anus/plugins/" .. plugin.id .. "/times.txt", util.TableToKeyValues( anus_autopromote ) )
end

local function CreateAutoPromote()
	anus_autopromote = (CLIENT and anus_autopromote or {}) or SERVER and {}
	
	if SERVER then
		local data = file.Read( "anus/plugins/" .. plugin.id .. "/times.txt" )
		if data then data = util.KeyValuesToTable( data ) end
		
		local difference = false
		
		anus_autopromote = data or {}
		for k,v in next, anus_autopromote or {} do
			if not anus.isValidGroup( k ) then
				difference = true
				anus_autopromote[ tostring( k ) ] = nil
			end

			anus_autopromote[ tostring( k ) ] = math.Round( v, 2 )
		end
		
		for k,v in next, anus.Groups do
			if not anus_autopromote[ tostring( k ) ] and k != "user" then
				difference = true
				anus_autopromote[ tostring( k ) ] = -1
			end
		end
		
		if difference then
			SaveAutoPromote()
		end
	end
end

local function AutoPromoteCanExist()
	return ( anus.getPlugins()[ "playertime" ] and not anus.getPlugins()[ "playertime" ].disabled ) and ( anus.getPlugins()[ "autopromote" ] and not anus.getPlugins()[ "autopromote" ].disabled ) and ( anus.getPlugins()[ "adduser" ] and not anus.getPlugins()[ "adduser" ].disabled )
end

function CheckAutoPromote( pl )
	if anus_autopromote[ pl:GetUserGroup() ] == -1 then return nil end
	
	local CurrentUserGroup = anus_autopromote[ pl:GetUserGroup() ] or 0
	local pltime = pl:getTotalTimePlayed() / ANUS_HOUR
	local time = 0
	local rank = nil

	for k,v in next, anus_autopromote or {} do
			-- if the group id was removed / changed
		if not anus.isValidGroup( k ) then continue end
		if v == -1 then continue end
		
		if v >= time and v <= pltime and v > CurrentUserGroup then
			time = v
			rank = k
		end
	end

	return rank, time
end

function plugin:OnLoad()
	CreateAutoPromote()
	
	if SERVER then
		net.Start( "anus_autopromotenetallcl" )
			net.WriteUInt( table.Count( anus_autopromote ), 6 )
			for k,v in next, anus_autopromote do
				net.WriteString( k )
				net.WriteFloat( v )
			end
		net.Broadcast()
	end
end

anus.registerPlugin( plugin )

if SERVER then
	util.AddNetworkString( "anus_autopromotenetallcl" )
	util.AddNetworkString( "anus_autopromotesv" )
	util.AddNetworkString( "anus_autopromotecl" )
	util.AddNetworkString( "anus_autopromoteremovegroupsv" )
	
	net.Receive( "anus_autopromotesv", function( len, pl )
		if not AutoPromoteCanExist() then return end
		if not pl:hasAccess( "autopromote" ) then
			anus.playerNotification( pl, "Access denied" )
			return
		end

		local time = math.Round( math.Clamp( net.ReadFloat(), -1, anus.convertStringToTime( "3y" ) / ANUS_HOUR ), 2 )
		local group = net.ReadString()

		anus_autopromote[ group ] = time
		SaveAutoPromote()
		
		net.Start( "anus_autopromotecl" )
			net.WriteString( group )
			net.WriteFloat( time )
		net.Broadcast()
	end )
	
	net.Receive( "anus_autopromoteremovegroupsv", function( len, pl )
		if not AutoPromoteCanExist() then return end
		if not pl:hasAccess( "autopromote" ) then
			anus.playerNotification( pl, "Access denied" )
			return
		end
		
		local group = net.ReadString()
		
		anus_autopromote[ group ] = nil
		SaveAutoPromote()
		
		net.Start( "anus_autopromotenetallcl" )
			net.WriteUInt( table.Count( anus_autopromote ), 6 )
			for k,v in next, anus_autopromote do
				net.WriteString( k )
				net.WriteFloat( v )
			end
		net.Broadcast()
	end )
end

anus.registerHook( "InitPostEntity", "autopromote", function()
	CreateAutoPromote()
end, plugin.id )

if SERVER then
	anus.registerHook( "anus_PlayerAuthenticated", "autopromote", function( pl )
		
		timer.createPlayer( pl, "anus_autopromotecheck", 10, 0, function()
			if not AutoPromoteCanExist() then return end
			
			local promotion = CheckAutoPromote( pl )
			if promotion and promotion != pl:GetUserGroup() then
				
				anus.playerNotification( nil, pl, " has been autopromoted to ", anus.Colors.String, promotion )
				anus.runCommand( "adduser", NULL, { pl }, promotion )
			
			end
		end )
		
		net.Start( "anus_autopromotenetallcl" )
			net.WriteUInt( table.Count( anus_autopromote ), 6 )
			for k,v in next, anus_autopromote do
				net.WriteString( k )
				net.WriteFloat( v )
			end
		net.Send( pl )
		
	end, plugin.id, nil, true )
else
	net.Receive( "anus_autopromotenetallcl", function()
		anus_autopromote = {}

		local count = net.ReadUInt( 6 )
		for i=1,count do
			anus_autopromote[ net.ReadString() ] = math.Round( net.ReadFloat(), 2 )
		end
		
		hook.Call( "anus_AutoPromoteGroupsBroadcasted", nil )
	end )

	net.Receive( "anus_autopromotecl", function()
		local group = net.ReadString()
		local time = math.Round( net.ReadFloat(), 2 )
		local oldtime = anus_autopromote[ group ]

		anus_autopromote[ group ] = time
		hook.Call( "anus_AutoPromoteGroupsChanged", nil, group, time, oldtime )
	end )
end

-- last seen

local plugin = {}
plugin.id = "lastseen"
plugin.chatcommand = "!lastseen"
plugin.name = "Last Seen"
plugin.author = "Shinycow"
plugin.arguments = {
	{ SteamID = "string" }
}
plugin.description = "Notifies time this steamid was last seen"
plugin.example = "!seen STEAM_0:0:29257121"
plugin.category = "Time"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, steamid )
	if not string.IsSteamID( steamid ) then
		anus.playerNotification( caller, "This steamid isn't valid." )
		return
	end
	
	local Dir = "anus/plugins/playertime/" .. anus.safeSteamID( steamid ) .. ".txt"
	if not file.Exists( Dir, "DATA" ) then
		anus.playerNotification( caller, "This steamid has no record." )
		return
	end
	
	local Data = von.deserialize( file.Read( Dir, "DATA" ) )
	local Formatted = os.date( "%Y/%m/%d - %H:%M:%S", Data.lastonline )
	
	anus.playerNotification( caller, "SteamID \"", anus.Colors.SteamID, steamid, "\" was last seen on ", anus.Colors.String, Formatted )
end

anus.registerPlugin( plugin )