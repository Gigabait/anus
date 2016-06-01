local _R = debug.getregistry()
function _R.Player:SetTotalTimePlayed( num )
	self:SetNW2Int( "anus_TotalTime", num )
end
function _R.Player:AddTotalTimePlayed( num )
	self:SetTotalTimePlayed( self:GetTotalTimePlayed() + num )
end
function _R.Player:GetTotalTimePlayed()
	return self:GetNW2Int( "anus_TotalTime", 0 ) + self:GetSessionTimePlayed()
end
function _R.Player:SetSessionTimePlayed( num )
	self:SetNW2Int( "anus_SessionTime", num )
end
function _R.Player:AddSessionTimePlayed( num )
	self:SetSessionTimePlayed( self:GetSessionTimePlayed() + num )
end
function _R.Player:GetSessionTimePlayed()
	return CurTime() - ( self.SessionJoinTime or CurTime() )
end

local plugin = {}
plugin.id = "playertime"
plugin.name = "Player Time"
plugin.author = "Shinycow"
plugin.usage = ""
plugin.help = "Keeps track of player activity"
plugin.example = ""
plugin.notRunnable = true
plugin.hasDataFolder = true
plugin.category = "Time"
plugin.defaultAccess = "owner"

function plugin:SavePlayer( pl )
	local dir = "anus/plugins/" .. self.id .. "/" .. anus.SafeSteamID( pl ) .. ".txt"
	local data = { total = pl:GetTotalTimePlayed(), lastonline = os.time(), lastsession = pl:GetSessionTimePlayed() }
	
	file.Write( dir, von.serialize( data ) )
end

function plugin:NewPlayer( pl )
	pl:SetTotalTimePlayed( pl:GetSessionTimePlayed() )
	
	self:SavePlayer( pl )
end

function plugin:LoadPlayerTime( pl )
	local dir = "anus/plugins/" .. self.id .. "/" .. anus.SafeSteamID( pl ) .. ".txt"
	
	pl.SessionJoinTime = CurTime()
	pl:SetSessionTimePlayed( 0 )
	
	if file.Exists( dir, "DATA" ) then
		local data = von.deserialize( file.Read( dir, "DATA" ) )
		pl:SetTotalTimePlayed( data.total )
		
		return true, data
	else
		self:NewPlayer( pl )
		return false
	end
end
	
anus.RegisterPlugin( plugin )

if SERVER then
	anus.RegisterHook( "PlayerInitialSpawn", "playertime", function( pl )
		local returning, data = plugin:LoadPlayerTime( pl )
		
		if returning then
			anus.PlayerNotification( nil, pl, " was last seen on ", COLOR_STRINGARGS, os.date( "%a, %b %d, %Y at %H:%M:%S", data.lastonline ) )
		else
			anus.PlayerNotification( nil, "Welcome to the server, ", pl )
		end
		
		timer.CreatePlayer( pl, "playertime", 180, 0, function()
			plugin:SavePlayer( pl )
		end )
	end, plugin.id )

	anus.RegisterHook( "player_disconnect", "playertime", function( data )
		local pl = Player( data.userid )
		if not pl.HasAuthed then return end
		
		plugin:SavePlayer( pl )
	end, plugin.id )
else
	anus.RegisterHook( "InitPostEntity", "playertime", function()
		LocalPlayer().SessionJoinTime = CurTime()
	end, plugin.id )
end


local plugin = {}
plugin.id = "autopromote"
plugin.name = "Auto Promote"
plugin.author = "Shinycow"
plugin.usage = ""
plugin.help = "Promotes players based on their time played"
plugin.example = ""
plugin.notRunnable = true
plugin.hasDataFolder = true
plugin.category = "Time"
plugin.defaultAccess = "owner"

local function SaveAutoPromote()
	file.Write( "anus/plugins/" .. plugin.id .. "/times.txt", util.TableToKeyValues( anus_autopromote ) )
end

local function CreateAutoPromote()
	anus_autopromote = {}
	
	if SERVER then
		local data = file.Read( "anus/plugins/" .. plugin.id .. "/times.txt" )
		if data then data = util.KeyValuesToTable( data ) end
		
		local difference = false
		
		anus_autopromote = data or {}
		for k,v in next, anus_autopromote or {} do
			if not anus.Groups[ k ] then
				difference = true
				anus_autopromote[ k ] = nil
			end
		end
		
		for k,v in next, anus.Groups do
			if not anus_autopromote[ k ] and k != "user" then
				difference = true
				anus_autopromote[ k ] = -1
			end
		end
		
		if difference then
			SaveAutoPromote()
		end
	end
end

local function AutoPromoteCanExist()
	return ( anus.GetPlugins()[ "playertime" ] and not anus.GetPlugins()[ "playertime" ].disabled ) and ( anus.GetPlugins()[ "adduser" ] and not anus.GetPlugins()[ "adduser" ].disabled )
end

function CheckAutoPromote( pl )
	if anus_autopromote[ pl:GetUserGroup() ] == -1 then return nil end

	local pltime = pl:GetTotalTimePlayed() / ANUS_HOUR
	local time = 0
	local rank = nil

	for k,v in next, anus_autopromote or {} do
		if v == -1 then continue end
		
		if v >= time and v <= pltime then
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
			for k,v in next, anus_autopromote do
				net.WriteString( k )
				net.WriteFloat( v )
			end
		net.Send( pl )
	end
end

anus.RegisterPlugin( plugin )

if SERVER then
	util.AddNetworkString( "anus_autopromotenetallcl" )
	util.AddNetworkString( "anus_autopromotesv" )
	util.AddNetworkString( "anus_autopromotecl" )
	
	net.Receive( "anus_autopromotesv", function( len, pl )
		if not AutoPromoteCanExist() then return end
		if not pl:HasAccess( "autopromote" ) then
			anus.PlayerNotification( pl, "Access denied" )
			return
		end

		local time = math.Round( math.Clamp( net.ReadFloat(), -1, anus.ConvertStringToTime( "3y" ) / ANUS_HOUR ), 2 )
		local group = net.ReadString()

		anus_autopromote[ group ] = time
		SaveAutoPromote()
		
		net.Start( "anus_autopromotecl" )
			net.WriteString( group )
			net.WriteFloat( time )
		net.Broadcast()
	end )
end

anus.RegisterHook( "InitPostEntity", "autopromote", function()
	CreateAutoPromote()
end, plugin.id )

if SERVER then
	anus.RegisterHook( "anus_PlayerAuthenticated", "autopromote", function( pl )
		
		timer.CreatePlayer( pl, "anus_autopromotecheck", 10, 0, function()
			if not AutoPromoteCanExist() then return end
			
			local promotion = CheckAutoPromote( pl )
			if promotion and promotion != pl:GetUserGroup() then
				
				anus.PlayerNotification( nil, pl:Nick() .. " has been autopromoted to " .. promotion )
				anus.RunCommand_adduser( NULL, nil, nil, pl:SteamID() .. " " .. promotion )
			
			end
		end )
		
		net.Start( "anus_autopromotenetallcl" )
			for k,v in next, anus_autopromote do
				net.WriteString( k )
				net.WriteFloat( v )
			end
		net.Send( pl )
		
	end, plugin.id )
else
	net.Receive( "anus_autopromotenetallcl", function()
		local count = table.Count( anus.Groups ) - 1
		
		for i=1,count do
			anus_autopromote[ net.ReadString() ] = math.Round( net.ReadFloat(), 2 )
		end
	end )
	
	net.Receive( "anus_autopromotecl", function()
		anus_autopromote[ net.ReadString() ] = math.Round( net.ReadFloat(), 2 )
	end )
end