--[[

	Groups
	
]]--

local GroupsDefault = false
AddCSLuaFile( "defaultgroups.lua" )
if not file.Exists( "anus/groups.txt", "DATA" ) then
	GroupsDefault = true
	include( "defaultgroups.lua" )
	AddCSLuaFile( "defaultgroups.lua" )
end

function anus.saveUsers()
	local AnusUsersCopy = table.Copy( anus.Users )
	for k,v in next, AnusUsersCopy do
		if not v.save then AnusUsersCopy[ k ] = nil end
	end
	file.Write( "anus/users.txt", von.serialize( AnusUsersCopy ) )
end

function anus.getGroups()
	return anus.Groups
end

function anus.countGroupsAccess( plugin )
	local Count = 0
	local Groups = {}
	for k,v in next, anus.getGroups() do
		if v.Permissions[ plugin ] then
			Count = Count + 1
			Groups[ #Groups + 1 ] = k
		end
	end

	return Count, Groups
end

function anus.getGroupInheritance( group )
	if not group then return nil end

	return anus.getGroups()[ group ].Inheritance
end

function anus.getGroupInheritanceTree( group )
	if not group then return nil end
	if not anus.getGroups()[ group ].Inheritance then return { group } end

	local Output = {}
	Output = { group }

	local function LoopThrough( prev, inheritance )
		Output[ #Output + 1 ] = inheritance

		if anus.Groups[ inheritance ].Inheritance then
			LoopThrough( inheritance, anus.getGroups()[ inheritance ].Inheritance )
		end
	end
	LoopThrough( nil, anus.getGroups()[ group ].Inheritance )

	return Output
end

function anus.getGroupDirectInheritance( group )
	if not group then return nil end
	if not anus.getGroups()[ group ].Inheritance then return { group } end

	local Output = {}
	Output = {}

	for k,v in next, anus.getGroups() do
		if k == group then continue end

		if v.Inheritance == group then
			Output[ #Output + 1 ] = k
		end
	end

	return Output
end

function anus.groupHasInheritanceFrom( group1, group2, samegroup )
	if not group1 or not group2 then return nil end
	if group1 == group2 and not samegroup then return false end

	local Tree = anus.getGroupInheritanceTree( group1 )
	for k,v in next, Tree do
		if v == group2 then
			return true
		end
	end

	return false
end


local function anus_GroupsInherit()
	for k,v in next, anus.getGroups() do
		if not v.Inheritance then continue end

		local function LoopThrough( group, inheritance, permissions )
			for a,b in next, permissions do
				if anus.getGroups()[ group ].Permissions[ a ] == nil then
					anus.getGroups()[ group ].Permissions[ a ] = b
				end
			end

			if not anus.getGroups()[ inheritance ].Inheritance then return end

			if anus.getGroups()[ inheritance ].Inheritance then
				LoopThrough( group, anus.getGroups()[ inheritance ].Inheritance, anus.getGroups()[ anus.getGroups()[ inheritance ].Inheritance ].Permissions )
			end
		end

		--print( k )
		--print( v.Inheritance )
		--print( anus.Groups[ v.Inheritance ] )
		LoopThrough( k, v.Inheritance, anus.getGroups()[ v.Inheritance ].Permissions )
	end
end
hook.Add( "Initialize", "anus_groupinheritance", anus_GroupsInherit )
hook.Add( "inherit", "fa", anus_GroupsInherit )

function anus.createGroup( id, name, inheritance, icon, color )
	if not id then return false, "Group ID must be supplied!" end
	if anus.isValidGroup( id ) then return false, "Group ID already exists!" end
	if inheritance and not anus.isValidGroup( inheritance ) then return false, "Inheritance group doesn't exist!" end

	name = name or id
	inheritance = inheritance or "user"

	local inherit = inheritance 

		-- id key is really not neccessary.
		-- remnants left over from old permission checking
		-- todo for that ^: Add function to return groups inherited from
		-- use that for every check for ids.
	anus.Groups[ id:lower() ] =
	{
	--id = math.random( 6, 99999 ),
	name = name,
	Inheritance = inherit,
	Permissions = {},
	icon = icon or "",
	color = color or Color( 125, 125, 125, 255 ),
	isadmin = anus.getGroups()[ inheritance ] and anus.getGroups()[ inheritance ].isadmin or nil,
	issuperadmin = anus.getGroups()[ inheritance ] and anus.getGroups()[ inheritance ].issuperadmin or nil
	}

	anus_GroupsInherit()
	anus.saveGroups( true )
	
	hook.Call( "anus_GroupSettingsChanged", nil, id )

	return anus.getGroups()[ id:lower() ]
end

function anus.removeGroup( id )
	if not id then return false, "Group ID must be supplied" end
	if not anus.isValidGroup( id ) then return false, "This isn't a valid group!" end
	if anus.getGroups()[ id ].hardcoded then return false, "This group cannot be removed!" end
	
	for k,v in ipairs( player.GetAll() ) do
		if v:GetUserGroup() == id then
			v:SetUserGroup( "user", true )
		end
	end
	for k,v in next, anus.Users do
		if v.group == id then
			anus.Users[ k ].group = "user"
		end
	end
	
	local Inheritance = anus.Groups[ id ].Inheritance
	Inheritance = Inheritance or "user"
	for k,v in next, anus.getGroups() do
		if v.Inheritance and v.Inheritance == id then
			anus.Groups[ k ].Inheritance = Inheritance
		end
	end
	anus.Groups[ tostring( id ):lower() ] = nil

	anus_GroupsInherit()
	anus.saveUsers()
	anus.saveGroups( true )
	hook.Call( "anus_GroupSettingsChanged", nil, id )

	return true
end

function anus.isValidGroup( group )
	if not group or not anus.getGroups()[ group ] then return false end

	return true
end

anus.groupPluginCache = {}
function anus.createGroupPluginCache( group, plugin )
	if not group then
		error( "anus.CreateGroupPluginCache: No group supplied.\nThis means something somewhere messed up.." )
	end
	anus.groupPluginCache[ group ] = anus.groupPluginCache[ group ] or {}
	--anus.groupPluginCache[ group ].Permissions = anus.groupPluginCache[ group ].Permissions or {}

	anus.groupPluginCache[ group ][ plugin ] = true
end

function anus.getPlayersInGroup( group )
	local Output = {}
	for k,v in next, anus.Users do
		if v.group == group then
			Output[ #Output + 1 ] = k
		end
	end

	return Output
end

--[[local function ParseGroupRestrictions( group, cmd, restrictions )
	local Args = anus.getPlugins()[ cmd ].arguments
	]]
	

function anus.groupAllow( group, cmd, restrictions, player )
	if not anus.isValidGroup( group ) then return false, group .. " is not a valid group" end
	if not anus.isValidPlugin( cmd:lower() ) and not anus.cvarsRegistered[ cmd:lower() ] and not anus.accessTags[ cmd:lower() ] then return false, "Not a valid command" end
		-- will need to change this later
	if restrictions and restrictions == "true" then restrictions = true end
	if anus.Groups[ group ].Permissions[ cmd:lower() ] then
		if ( restrictions and restrictions == anus.Groups[ group ].Permissions[ cmd:lower() ] ) or 
		not restrictions then 
			return false, group .. " already has access to " .. cmd
		end
	end
	
	anus.Groups[ group ].Permissions[ cmd:lower() ] = restrictions or true
	anus.saveGroups( true )
	
	hook.Call( "anus_GroupSettingsChanged", nil, group, player )
	
	return true
end

function anus.groupDeny( group, cmd, player )
	if not anus.isValidGroup( group ) then return false, group .. " is not a valid group" end
	if not anus.isValidPlugin( cmd:lower() ) and not anus.cvarsRegistered[ cmd:lower() ] and not anus.accessTags[ cmd:lower() ] then return false, "Not a valid command" end
	if not anus.Groups[ group ].Permissions[ cmd:lower() ] then return false, group .. " is already denied access from " .. cmd end
	
	anus.Groups[ group ].Permissions[ cmd:lower() ] = false
	anus.saveGroups( true )
	
	hook.Call( "anus_GroupSettingsChanged", nil, group, player )
	
	return true
end

function anus.saveGroups( bbroadcast )
	file.Write( "anus/groups.txt", von.serialize( anus.getGroups() ) )
	if bbroadcast then
		for k,v in ipairs( player.GetAll() ) do
			anusNetworkGroups( v )
		end
	end
end

hook.Add( "Initialize", "anus_GrabDataInfo", function()
	if file.Exists( "anus/users.txt", "DATA" ) then
		anus.Users = von.deserialize( file.Read( "anus/users.txt", "DATA" ) )
		for k,v in next, anus.Users do
			if v.expiretime then
				anus.tempUsers[ k ] = { group = v.group, time = v.expiretime }
			end
		end
	end

	if file.Exists( "anus/groups.txt", "DATA" ) then
		anus.Groups = von.deserialize( file.Read( "anus/groups.txt", "DATA" ) )
		for k,v in next, anus.groupPluginCache do
			local Group = k
			if not anus.isValidGroup( Group ) then Group = "user" end
			if not anus.isValidGroup( Group ) then
				Error( "User group has been deleted! Remove data/anus/groups.txt and start over.\n" )
				return
			end

			for key, value in next, v do
				if not anus.getGroups()[ Group ].Permissions[ key ] then
					anus.Groups[ Group ].Permissions[ key ] = true
				end
			end
		end
	else
		timer.Create( "anus_firstrun", 2, 1, function()
			anus.saveGroups()
		end )
	end

	ANUSGROUPSLOADED = true
	hook.Call( "anus_SVGroupsLoaded", nil )
end )


function anus.changeGroupName( group, name, player )
	if not anus.isValidGroup( group ) then return false, "Incorrect group supplied" end
	if #name > 28 then return false, "Name is too long" end
	local FoundChar = false
	for i=1,#name do
		if name[ i ] != " " then
			FoundChar = true
			break
		end
	end
	if not FoundChar then return false, "Supply a valid name" end

	anus.Groups[ group ][ "name" ] = name
	anus.saveGroups( true )
	hook.Call( "anus_GroupSettingsChanged", nil, group, player )

	return true
end

function anus.changeGroupID( group, id, player )
	if not anus.isValidGroup( group ) then return false, "Not a valid group" end
	if anus.Groups[ group ].hardcoded then return false, "This group's ID cannot be changed!" end
	if anus.isValidGroup( id ) then Error( "Group id " .. id .. " already exists!\n" ) return false, "The ID is already registered to another group" end

	local Tbl = anus.getGroupDirectInheritance( group )
	anus.Groups[ id ] = table.Copy( anus.Groups[ group ] )
	anus.Groups[ group ] = nil

	for k,v in next, Tbl do
		anus.Groups[ v ].Inheritance = id
	end
	anus.saveGroups( true )

	for k,v in next, anus.Users do
		if v.group == group then
			anus.Users[ k ].group = id
		end
	end
	anus.saveUsers()

	for k,v in ipairs( player.GetAll() ) do
		if v:isAnusSendable() then
			anusBroadcastUsers( v )
		end
	end
	
	hook.Call( "anus_GroupSettingsChanged", nil, group, player )

	return true
end

	-- todo
function anus.changeGroupInheritance( group, inheritance, player )
	if not anus.Groups[ group ] then return false, "Not a valid group" end
	if inheritance == group or group == "user" then return false, "Denied: Infinite loop prevention" end
	
	anus.Groups[ group ].Inheritance = inheritance
	hook.Call( "anus_GroupSettingsChanged", nil, group, player )
end

function anus.changeGroupColor( group, color, player )
	if not anus.Groups[ group ] then return false, "Not a valid group" end
	if not IsColor( color ) then return false, "Not a color" end
	
	anus.Groups[ group ].color = color
	anus.saveGroups( true )
	hook.Call( "anus_GroupSettingsChanged", nil, group, player )
	
	return true
end

function anus.changeGroupIcon( group, icon, player )
	if not anus.isValidGroup( group ) then return false, "Not a valid group" end
	
	local Find = file.Exists( "materials/" .. icon, "GAME" )
	if not Find then return false, "Not a valid icon" end
	
	anus.Groups[ group ].icon = icon
	anus.saveGroups( true )
	hook.Call( "anus_GroupSettingsChanged", nil, group, player )
	
	return true
end

if not timer.Exists( "anus_refreshtemps" ) then
	timer.Create( "anus_refreshtemps", 2, 0, function()
		for k,v in ipairs( player.GetAll() ) do
			if anus.tempUsers[ v:SteamID() ] then
				if os.time() >= anus.tempUsers[ v:SteamID() ].expiretime then
					chat.AddText( nil, team.GetColor( v:Team() ), v:Nick(), color_white, " time for ", Color( 180,180,255, 255 ), anus.tempUsers[ v:SteamID() ].group, color_white, " has expired and has been demoted." )
					anus.Users[ v:SteamID() ] = nil
					anus.tempUsers[ v:SteamID() ] = nil
					v:SetUserGroup( "user" )
					anus.saveUsers()
				end
			end
		end
	end )
end

util.AddNetworkString( "anus_settings_groupchanged" )
hook.Add( "anus_GroupSettingsChanged", "anus_GroupSettingsChanged", function( group )
	-- broadcast to poeple allowed to change group settings
	-- for people in the gorup settings menu, notify them a change ahs occured
	-- buttons are "Close, start over" and "Continue editing"
	local Send = {}
	for k,v in ipairs( player.GetAll() ) do
		if v:hasAccess( "addgroup" ) then
			Send[ #Send + 1 ] = v
		end
	end
	net.Start( "anus_settings_groupchanged" )
		net.WriteString( group )
	net.Send( Send )
end )


--[[

	Teams
	
]]--
util.AddNetworkString( "anus_network_teams" )
util.AddNetworkString( "anus_sv_receiveteamsettings" )

anus.teamsTable = anus.teamsTable or {}

	-- Yes, this is inspired from ULX
	-- Having it setup like this allows easier transfer ULX->ANUS
local AnusTeamStartIndex = 21
local AnusDefaultTeamModifiers =
{
	[ "Armor" ] = { default = 0, min = 0, max = 2^15-1 },
	[ "DuckSpeed" ] = { default = 0.15, min = 0, max = 5, decimals = 2 },
	[ "Gravity" ] = { default = 1, min = -1, max = 5, decimals = 2 },
	[ "Health" ] = { default = 100, min = 1, max = 2^31-1 },
	[ "JumpPower" ] = { default = 200, min = 0, max = 4000 },
	[ "MaxHealth" ] = { default = 100, min = 1, max = 2^31-1 },
	[ "Model" ] = "gman",
	[ "RunSpeed" ] = { default = 400, min = 5, max = 2500 },
	[ "StepSize" ] = { default = 18, min = 0, max = 512, decimals = 2 },
	[ "UnDuckSpeed" ] = { default = 0.1, min = 0, max = 5, decimals = 2 },
	[ "WalkSpeed" ] = { default = 200, min = 1, max = 2500 },
}
local AnusDefaultTeamModifiersSorted = {}
for k,v in next, AnusDefaultTeamModifiers do
	AnusDefaultTeamModifiersSorted[ #AnusDefaultTeamModifiersSorted + 1 ] = k
end

anus.teams_Next_Index = 21

function anus.getTeams()
	return anus.teamsTable
end

function anus.anusTeamsAllowed()
	return GAMEMODE.Name != "DarkRP"
end

function anus.networkTeams( pl )
	net.Start( "anus_network_teams" )
		net.WriteTable( anus.getTeams() )
	if pl then
		net.Send( pl )
	else
		net.Broadcast()
	end
end

function anus.createTeam( name, tblcolor )
	if not name then return false, "A valid name must be supplied!" end
	
	local Found = false
	for k,v in ipairs( anus.getTeams() ) do
		if v.name:lower() == name:lower() then
			Found = true
			break
		end
	end
	
	if Found then return false, "A unique name must be given!" end
		
	if isstring( tblcolor ) then
		tblcolor = string.Explode( " ", tblcolor )
	end

	local TblColor = tblcolor or Color( 255, 255, 255, 255 )
	TblColor = Color( TblColor.r or TblColor[ 1 ], TblColor.g or TblColor[ 2 ] or 255, TblColor.b or TblColor[ 3 ] or 255, 255 )
	
	anus.teams_Next_Index = anus.teams_Next_Index + 1
	
	anus.getTeams()[ #anus.getTeams() + 1 ] = 
	{ 
		name = name, 
		color = TblColor,
		teamindex = anus.teams_Next_Index,
		Modifiers = {},
		Groups = {},
	}
	
	anus.doTeamSetup( #anus.getTeams() )
	anus.saveTeams()
	
	return #anus.getTeams(), TblColor
end

function anus.removeTeam( name )
	if not name then return false, "A valid name must be supplied!" end

	local Found = false
	for k,v in ipairs( anus.getTeams() ) do
		if v.name:lower() == name:lower() then
			for group in next, v.Groups do
				anus.changeGroupTeams( group, "" )
			end

			table.remove( anus.getTeams(), k )
			Found = true
		end
	end
	
	if not Found then return false, "Not a valid team!" end
	
	anus.refreshTeamSetups()
	return true
end

function anus.changeGroupTeam( group, newteam )
	for k,v in ipairs( anus.getTeams() ) do	
		v.Groups[ group ] = nil
	
		if v.name:lower() == newteam:lower() then
			v.Groups[ group ] = true
		end
	end
	
	anus.refreshTeamSetups()
end

function anus.changeTeamName( name, newname )
	for k,v in ipairs( anus.getTeams() ) do
		if v.name:lower() != name:lower() then continue end
		
		v.name = newname
		break
	end
	
	anus.refreshTeamSetups()
end
			

function anus.changeTeamModifier( name, modifier, newamount )
	if modifier != "color" and not AnusDefaultTeamModifiers[ modifier ] then return false, "Not a valid modifier!" end

	newamount = tonumber( newamount ) or newamount
	
	for k,v in ipairs( anus.getTeams() ) do
		if v.name:lower() != name:lower() then continue end
		
		if modifier == "color" then
			v.color = newamount
		else
			if newamount == "" then
				v.Modifiers[ modifier ] = nil
				return
			end
			
			if istable( AnusDefaultTeamModifiers[ modifier ] ) then
				local Default = AnusDefaultTeamModifiers[ modifier ]
				if Default.decimals then
					newamount = math.Round( newamount, Default.decimals )
				end

				if Default.min > newamount then
					newamount = Default.min
				elseif Default.max < newamount then
					newamount = Default.max
				end
			end
			v.Modifiers[ modifier ] = newamount
		end
	end
	
	anus.refreshTeamSetups()
end

local PlyMetaTable = FindMetaTable( "Player" )
local EntMetaTable = FindMetaTable( "Entity" )
function anus.applyTeamModifier( pl, name, modifier )
	if not AnusDefaultTeamModifiers[ modifier ] then return false, "Not a valid modifier!" end
	
	for k,v in ipairs( anus.getTeams() ) do
		if v.name:lower() != name:lower() then continue end
		
		local Amount = v.Modifiers[ modifier ]
		
		if PlyMetaTable[ "Set" .. modifier ] then
			PlyMetaTable[ "Set" .. modifier ]( pl, Amount )
		else
			EntMetaTable[ "Set" .. modifier ]( pl, Amount )
		end
		break
	end
end

function anus.refreshTeamSetups()
	if not anus.anusTeamsAllowed() then return end
	
	anus.teams_Next_Index = AnusTeamStartIndex
	
	for k,v in ipairs( anus.getTeams() ) do
		team.SetUp( anus.teams_Next_Index, v.name, v.color )
		v.teamindex = anus.teams_Next_Index
		anus.teams_Next_Index = anus.teams_Next_Index + 1
	end
	
	anus.networkTeams()
	for k,v in ipairs( player.GetAll() ) do
		anus.setPlayerTeam( v )
	end
	
	anus.saveTeams()
end

function anus.doTeamSetup( index )
	if not anus.anusTeamsAllowed() then return end
	
	team.SetUp( index, anus.getTeams()[ index ].name, anus.getTeams()[ index ].color )
	anus.teams_Next_Index = anus.teams_Next_Index + 1 -- index?
	
	anus.networkTeams()
end
	
function anus.setPlayerTeam( pl )
		-- i know i know, but we don't set player team until 0.03 after initialspawn
	timer.createPlayer( pl, "anus_AssignTeamDelay", 0.03 + 0.01, 1, function()
		local Found = false
		for k,v in ipairs( anus.getTeams() ) do
			--if not v.Groups then continue end
			
			if v.Groups[ pl:GetUserGroup() ] then
				Found = true
				timer.createPlayer( pl, "anus_AssignTeam", 0.25, 1, function()
					pl:SetTeam( v.teamindex )
					if v.Modifiers[ "Model" ] then
						pl:SetModel( v.Modifiers[ "Model" ] )
					end
					
					for k,v in next, v.Modifiers do
						if PlyMetaTable[ "Set" .. k ] then
							PlyMetaTable[ "Set" .. k ]( pl, v )
						else
							EntMetaTable[ "Set" .. k ]( pl, v )
						end
					end
				end )
			end
		end
		
		if not Found then
			if pl:Team() >= AnusTeamStartIndex and pl:Team() < anus.teams_Next_Index then
				timer.createPlayer( pl, "anus_AssignTeam", 0.25, 1, function()
					pl:SetTeam( TEAM_UNASSIGNED )
				end )
			end
		end
	end )
end
hook.Add( "PlayerSpawn", "anus_Teams_DoTeamSpawn", anus.setPlayerTeam )
--hook.Add( "anus_PlayerFullyLoaded", "anus_DoTeamSpawn", anus.setPlayerTeam )
hook.Add( "PlayerInitialSpawn", "anus_Teams_DoTeamSpawn", anus.networkTeams )

function anus.saveTeams( broadcast )
	file.Write( "anus/teams.txt", von.serialize( anus.getTeams() ) )
end

function anus.loadTeams()
	anus.teamsTable = von.deserialize( file.Read( "anus/teams.txt", "DATA" ) )
end
hook.Add( "anus_SVGroupsLoaded", "anus_Teams_LoadTeams", anus.loadTeams )

net.Receive( "anus_sv_receiveteamsettings", function( len, pl )
	if not pl:hasAccess( "modifyTeams" ) then return end
	
	local Tbl = net.ReadTable()
	local Index = 0
	
	for k,v in ipairs( anus.getTeams() ) do
		if v.name == Tbl.TeamName then
			Index = k
			break
		end
	end
	
	if Index == 0 then return end
	
	if Tbl.GroupID then
		anus.changeGroupTeam( Tbl.GroupID, Tbl.TeamName )
	end
	
	if Tbl.color and Tbl.color != anus.getTeams()[ Index ].color then
		anus.changeTeamModifier( Tbl.TeamName, "color", Tbl.color )
	end
	
	if Tbl.Modifiers then
		for k,v in next, Tbl.Modifiers do
			anus.changeTeamModifier( Tbl.TeamName, k, v )
		end
	end
	
	if Tbl.name and Tbl.name != Tbl.TeamName then
		anus.changeTeamName( Tbl.TeamName, Tbl.name )
	end
end )
	

--[[

	Bans
	
]]--

if anus.enableSourceBans then
	require( "sourcebans" )
end

function anus.saveBans()
	file.Write( "anus/bans.txt", von.serialize( anus.Bans ) )
end

--[[function anus.banPlayer( caller, target, reason, time )
	caller = IsValid( caller ) and caller or Entity( 0 )

	local IntTime = os.time() + time
	if time == 0 then IntTime = 0 end

	if isstring( target ) then
		target = target:gsub( "\"", "" )
	end

	local Info = { steamid = target, ip = "", name = target, reason = reason or "No reason given.", dateofban = os.time(), time = IntTime, admin = caller:Nick(), admin_steamid = caller:SteamID() }
	if not isstring( target ) and IsValid( target ) then
		Info.steamid = target:SteamID()
		Info.name = target:Nick()
		Info.ip = target:IPAddress()

		if anus.enableSourceBans then
				-- sourcebans 1.4
			sourcebans.banPlayer( target, (IntTime - os.time()) / 60, reason, caller )
		end
		timer.createPlayer( target, "anus_kickbanplayer", 0.1, 1, function()
			target:Kick( "Banned. (" .. reason .. ").\nCheck console for details." )
		end )
	else
		if anus.enableSourceBans then
			sourcebans.BanPlayerBySteamID( target, (IntTime - os.time()) / 60, reason, caller, target )
		end
	end

	if file.Exists( "anus/bans.txt", "DATA" ) then
		anus.Bans = von.deserialize( file.Read( "anus/bans.txt", "DATA" ) )
	end
	timer.Create( "AddBannedPlayer" .. math.random(1,99999), 0.03, 1, function()
		anus.Bans[ Info.steamid ] = { name = Info.name, ip = Info.ip, reason = Info.reason, dateofban = Info.dateofban, time = Info.time, admin = Info.admin, admin_steamid = Info.admin_steamid }

		anus.saveBans()
		for k,v in ipairs( player.GetAll() ) do
			if v:hasAccess( "unban" ) then
				if not v.BroadcastedBans then
					anusBroadcastBans( v )
				else
					anusBroadcastBans( v, true, Info.steamid )
				end
			end
		end
	end )

	file.CreateDir( "anus/users/" .. anus.safeSteamID( Info.steamid ) )

	if time and time != 0 then
		anus.banExpiration[ Info.steamid ] = os.time() + time
	elseif not time or time == 0 and anus.banExpiration[ Info.steamid ] then
		anus.banExpiration[ Info.steamid ] = nil
	end
end

function anus.unbanPlayer( caller, steamid, opt_reason )
	opt_reason = opt_reason or "Unbanned"
	local Caller_Color = Color( 10, 10, 10, 255 )
	if IsValid( caller ) then
		Caller_Color = team.GetColor( caller:Team() )
	end
	if anus.Bans[ steamid ] then
		chat.AddText( nil, Color( 191, 255, 127, 255 ), steamid, color_white, " (", Color( 191, 255, 127, 255 ), anus.Bans[ steamid ].name, color_white, ") was unbanned by ", Caller_Color, caller:Nick(), color_white, " (", anus.Colors.String, opt_reason, color_white, ")" )
		print( steamid .. " was unbanned by " .. caller:Nick() )
	else
		chat.AddText( nil, Color( 191, 255, 127, 255 ), steamid, color_white, " was unbanned by ", Caller_Color, caller:Nick() )
		print( steamid .. " was unbanned by " .. caller:Nick() )
	end

	local History = "anus/users/" .. anus.safeSteamID( steamid ) .. "/banhistory.txt"
	local Bans = anus.Bans[ steamid ]
	local Data = {}
	if file.Exists( History, "DATA" ) then
		Data = von.deserialize( file.Read( History, "DATA" ) )
	end

	Data[ #Data + 1 ] = { admin_steamid = Bans.admin_steamid, name = Bans.name, reason = Bans.reason, dateofban = Bans.dateofban or nil, time = Bans.time }
	file.Write( History, von.serialize( Data ) )

	anus.Bans[ steamid ] = nil
	if anus.banExpiration[ steamid ] then
		anus.banExpiration[ steamid ] = nil
	end
	anus.saveBans()
	game.ConsoleCommand( "removeid " .. steamid .. "\n" )

	for k,v in ipairs( player.GetAll() ) do
		if anus.Groups[ v.anusUserGroup or "user" ][ "Permissions" ].unban then
			if not v.BroadcastedBans then
				anusBroadcastBans( v )
			else
				anusBroadcastUnban( v, steamid )
			end
		end
	end
end]]

function anus.banPlayer( caller, target, reason, time )
	local BanInfo = {}
	local TargetName
	local TargetIP
	time = time or 0

	if not isstring( target ) and IsValid( target ) then
		TargetName = target:Nick()
		TargetIP = target:IPAddress()
		target = target:SteamID()
	elseif isstring( target ) then
		target = string.gsub( target, "\"", "" )
		if not string.IsSteamID( target ) then return end
		TargetName = target
	end

	local PreviouslyBanned = false
	if anus.Bans[ target ] then
		BanInfo = anus.Bans[ target ]
		BanInfo.reason_old = BanInfo.reason
		BanInfo.admin_steamid_modified = caller:SteamID()

		PreviouslyBanned = true
	else
		BanInfo.admin = caller:Nick()
		BanInfo.admin_steamid = caller:SteamID()
	end
	BanInfo.name = TargetName
	BanInfo.ip = TargetIP or ""
	BanInfo.reason = reason or "No reason given."
	BanInfo.dateofban = os.time()
	BanInfo.banlength = time
	BanInfo.unbandate = (time != 0 and os.time() + time) or 0
	anus.Bans[ target ] = BanInfo

	if anus.enableSourceBans then
		sourcebans.BanPlayerBySteamID( target, BanInfo.banlength, BanInfo.reason, caller, target )
	end
	timer.Create( "anus_kickbanplayer" .. os.time(), 0.1, 1, function()
		game.ConsoleCommand( "kickid " .. target .. " Banned. Check console for details\n" )
	end )

	anus.saveBans()
	for k,v in ipairs( player.GetAll() ) do
		if v:hasAccess( "unban" ) then
			if not v.anusNetworkedBans then
				anusNetworkBans( v )
			else
				anusNetworkBans( v, true, target )
			end
		end
	end

	if not PreviouslyBanned then
		file.CreateDir( "anus/users/" .. anus.safeSteamID( target ) )
	end

	if time and time != 0 then
		anus.banExpiration[ target ] = os.time() + time
	elseif not time or time == 0 and anus.banExpiration[ target ] then
		anus.banExpiration[ target ] = nil
	end
end

function anus.unbanPlayer( caller, steamid, reason )
	local History = "anus/users/" .. anus.safeSteamID( steamid ) .. "/banhistory.txt"
	local Bans = anus.Bans[ steamid ]
	local Data = {}

	if file.Exists( History, "DATA" ) then
		Data = von.deserialize( file.Read( History, "DATA" ) )
	end
	Data[ #Data + 1 ] = Bans

	file.Write( History, von.serialize( Data ) )

	anus.Bans[ steamid ] = nil
	anus.banExpiration[ steamid ] = nil
	anus.saveBans()
		-- In case theyre banned from some other means
	game.ConsoleCommand( "removeid " .. steamid .. "\n" )
	game.ConsoleCommand( "writeid\n" )

	for k,v in ipairs( player.GetAll() ) do
		if v:hasAccess( "unban" ) then
			if not v.anusNetworkedBans then
				anusNetworkBans( v )
			else
				anusNetworkUnban( v, steamid )
			end
		end
	end
end
	

if anus.enableSourceBans then
	hook.Add( "Initialize", "anus_SourcebansInteractive", function()
		timer.Simple( 1, function()
			local Db = sourcebans.getDatabaseObject()
			--local formatted = "INSERT INTO %s_admins ( name, auth, identity ) VALUES( '%s', 'steam', '%s' )"
			local Formatted = "INSERT INTO %s_admins ( name, auth, identity, create_time ) SELECT * FROM ( SELECT '%s', 'steam', '%s', %i ) AS tmp WHERE NOT EXISTS ( SELECT identity FROM %s_admins WHERE identity = '%s' ) LIMIT 1"
			for k,v in next, anus.Users do
				local Query = Db:query( string.format( Formatted, sourcebans.getDatabasePrefix(), v.name, k, os.time(), sourcebans.getDatabasePrefix(), k ) )
				Query:start()
			end

			local Formatted2 = "REPLACE INTO %s_admins ( name, auth, identity, create_time ) VALUES ( '%s', 'steam', '%s', %i )"
			hook.Add( "anus_PlayerGroupChanged", "anus_SourcebansInteractive", function( bvalidPlayer, pl, oldgroup, newgroup, time, save )
				local SteamId = bvalidPlayer and pl:SteamID() or pl
				
				local Query = Db:query( string.format( Formatted2, sourcebans.getDatabasePrefix(), bvalidPlayer and pl:Nick() or pl, SteamId, os.time() ) )
				--local query = db:query( string.format( formatted, sourcebans.getDatabasePrefix(), bValidPlayer and pl:Nick() or pl, steamid, sourcebans.getDatabasePrefix(), steamid ) )
				Query:start()
			end )
		end )
	end )

	local function convertBans()
		sourcebans.GetAllActiveBans(
			function( bans )
				for k,v in ipairs( bans ) do
					print( "[anus] linking sourcebans -> gmod: ", v.SteamID )
					anus.Bans[ v.SteamID ] = { name = v.Name, ip = v.IPAddress, reason = v.BanReason, dateofban = v.BanStart, time = v.BanLength, admin = v.AdminName, admin_steamid = v.AdminID }
					if anus.Bans[ v.SteamID ][ "time" ] != 0 then
						anus.Bans[ v.SteamID ][ "time" ] = v.BanEnd--anus.Bans[ v.SteamID ][ "time" ] + os.time()
					end
				end
			end
		)

		timer.Simple( 240, function() convertBans() end )
	end

	convertBans()
end

hook.Add( "InitPostEntity", "anus_CheckBannedPlayers", function()
	if file.Exists( "anus/bans.txt", "DATA" ) then
		anus.Bans = von.deserialize( file.Read( "anus/bans.txt", "DATA" ) )
	end

	anus.banExpiration = {}
	for k,v in next, anus.Bans do
		if v.unbandate and tonumber( v.unbandate ) != 0 then
			anus.banExpiration[ k ] = v.unbandate
		end
	end

	timer.Create( "anus_autounbanbanned", 3, 0, function()
		local OsTime = os.time
		local tonumber = tonumber
		for k,v in next, anus.banExpiration do
			v = tonumber( v )
			if v != 0 then
				if OsTime() >= v then
					anus.runCommand( "unban", Entity( 0 ), k, "Time expired" )
				end
			else
					-- their time was changed. remove them here.
				anus.banExpiration[ k ] = nil
			end
		end
	end )
end )

local ConnectLastRetry = {}
hook.Add( "CheckPassword", "anus_DenyBannedPlayer", function( steamid, ip, svpw, clpw, name )
	if anus.Bans[ util.SteamIDFrom64( steamid ) ] then
		local Info = anus.Bans[ util.SteamIDFrom64( steamid ) ]
		local Time = 10
		local BanMsg = "Your ban will expire in " .. Time .. " minutes"

		if Info.unbandate == 0 then
			Time = 0
			BanMsg = "Your ban won't expire"
		else
			Time = anus.convertTimeToString( Info.unbandate - os.time() )
			Banmsg = "Your time will expire in " .. Time
		end

		if not ConnectLastRetry[ steamid ] or ConnectLastRetry[ steamid ] <= CurTime() then
			anus.serverLog( "Banned player " .. Info.name .. " (" .. util.SteamIDFrom64( steamid ) .. " ) (" .. ip .. ") tried to connect.", true )
			chat.AddText( nil, color_white, "Banned player ", Color( 191, 255, 127, 255 ), Info.name, color_white, " (", Color( 191, 255, 127, 255 ), util.SteamIDFrom64( steamid ), color_white, ") tried to connect." )

			ConnectLastRetry[ steamid ] = CurTime() + 5
		end

		return false, [[
			You are banned!
			]] .. BanMsg .. [[
			
			Your steamid is ]] .. util.SteamIDFrom64( steamid ) .. [[
			
			You were banned by ]] .. Info.admin .. [[
			
			Their steamid is ]] .. Info.admin_steamid .. [[
			
			You were banned for ]] .. Info.reason
	end
end )


util.AddNetworkString( "anus_bans_editreason" )

net.Receive( "anus_bans_editreason", function( len, pl )
	if not pl:hasAccess( "unban" ) then return end

	local SteamId = net.ReadString()
	local Reason = net.ReadString()

	if not anus.Bans[ SteamId ] then return end

	anus.Bans[ SteamId ][ "reason" ] = Reason
	anus.saveBans()

	for k,v in ipairs( player.GetAll() ) do
		if anus.Groups[ v.anusUserGroup or "user" ]["Permissions"].unban then
			anusNetworkBans( v )
		end
	end
end )

util.AddNetworkString( "anus_bans_edittime" )

net.Receive( "anus_bans_edittime", function( len, pl )
	if not pl:hasAccess( "unban" ) then return end

	local SteamId = net.ReadString()
	local Time = net.ReadString()

	if not anus.Bans[ SteamId ] then return end

	if not tonumber( Time ) then
		Time = anus.convertStringToTime( Time ) or anus.convertStringToTime( "1m" )
	elseif tonumber( Time ) and time == "0" then
		Time = anus.convertStringToTime( Time )
	elseif tonumber( Time ) then
		Time = anus.convertStringToTime( Time .. "m" )
	end


	--[[time = tonumber( time ) or anus.convertStringToTime( time )
	if not time then
		time = "1d"
	end]]

	anus.Bans[ SteamId ][ "time" ] = Time == 0 and 0 or os.time() + Time
	anus.saveBans()

	for k,v in ipairs( player.GetAll() ) do
		if anus.Groups[ v.anusUserGroup or "user" ]["Permissions"].unban then
			anusNetworkBans( v )
		end
	end
end )

--[[

	Lua
	
]]--

	-- meep
local _R = debug.getregistry()
if not OLD_ERROR then
	OLD_ERROR = _R[ 1 ]
	_R[ 1 ] = function( ... )
		pcall( hook.Call, "LuaError", gmod.GetGamemode(), ... )
		return OLD_ERROR( ... )
	end
end

--[[

	Hooks
	
]]--

anus.Hooks = {}
anus.hooksCache = {}

local AnusHooksToCache =
{
	[ "InitPostEntity" ] = true,
	[ "Initialize" ] = true,
	[ "PostGamemodeLoaded" ] = true,
}

function anus.registerHook( hookname, unique, callback, pluginid, bno_override, runonload )
	if not bno_override then
		unique = "anus_plugin_" .. pluginid .. "_" .. (unique or "")
	end

	anus.Hooks[ hookname ] = anus.Hooks[ hookname ] or {}
	anus.Hooks[ hookname ][ unique ] = { func = callback, pluginid = pluginid, active = true, runonload = runonload }

	if anus.getPlugins()[ pluginid ] and not anus.isPluginDisabled( pluginid ) then
		--print( "register hook\n" )
		--print( hookname, unique, callback )
		--print( "\n" )
		anus.getPlugins()[ pluginid ].Hooks = anus.getPlugins()[ pluginid ].Hooks or {}
		anus.getPlugins()[ pluginid ].Hooks[ hookname ] = anus.getPlugins()[ pluginid ].Hooks[ hookname ] or {}

		anus.getPlugins()[ pluginid ].Hooks[ hookname ][ unique ] = callback

		hook.Add( hookname, unique, callback )

		if AnusHooksToCache[ hookname ] then
			callback()
		end
		
			-- referenced by anus.pluginLoad
		if bno_override and runonload then
			for _,players in ipairs( player.GetAll() ) do
				callback( players )
			end
		end
	else
		anus.Hooks[ hookname ][ unique ].active = false
		--[[if anusHooksToCache[ hookname ] then
			anus.HooksCache[ hookname ] = {}
			anus.HooksCache[ hookname ][ unique ] = true
		end]]
	end
end

function anus.unregisterHook( hookname, unique, pluginid, bno_override )
	if not bno_override then
		unique = "anus_plugin_" .. pluginid .. "_" .. (unique or "")
	end
	hook.Remove( hookname, unique )

	if anus.Hooks[ hookname ][ unique ][ "pluginid" ] then
		anus.Hooks[ hookname ][ unique ][ "active" ] = false
	end

	if anus.getPlugins()[ pluginid ] then
		anus.getPlugins()[ pluginid ].Hooks = anus.getPlugins()[ pluginid ].Hooks or {}
		anus.getPlugins()[ pluginid ].Hooks[ hookname ] = anus.getPlugins()[ pluginid ].Hooks[ hookname ] or {}
		anus.getPlugins()[ pluginid ].Hooks[ hookname ][ unique ] = nil
	end
end

function anus.getActivePluginHooks( pluginid )
	if not anus.getPlugins()[ pluginid ] then return {} end

	local Output = {}

	for k,v in next, anus.getPlugins()[ pluginid ].Hooks or {} do
		for key,value in next, v do
			Output[ k ] = Output[ k ] or {}
			Output[ k ][ key ] = value
		end
	end

	return Output, anus.getPlugins()[ pluginid ] != nil
end

function anus.getAllPluginHooks( pluginid )
	--if not anus.getPlugins()[ pluginid ] then return nil end

	local Output = {}

	for k,v in next, anus.Hooks or {} do
		for key,value in next, v do
			if value.pluginid == pluginid then
				Output[ k ] = Output[ k ] or {}
				Output[ k ][ key ] = value.func
			end
		end
	end

	return Output, anus.getPlugins()[ pluginid ] != nil
end

--[[

	Plugins
	
]]--

anus.pluginsTable = {}
anus.unloadedPlugins = anus.unloadedPlugins or {}

if anus.loadPlugins then anus.loadPlugins() end

function anus.isValidPlugin( plugin )
	return anus.getPlugins()[ plugin ] != nil
end
anus.pluginExists = anus.isValidPlugin

function anus.registerPlugin( tbl )
	if not tbl then
		Error( debug.getinfo( 1, "S" ).short_src .. " didn't supply plugin table.\n" )
		return
	end

	if anus.countGroupsAccess( tbl.id ) == 0 then
		local Group = tbl.defaultAccess

		if not anus.Groups[ Group ] then
			anus.createGroupPluginCache( Group, tbl.id )
		else
			anus.Groups[ Group ].Permissions = anus.Groups[ Group ].Permissions or {}
			anus.Groups[ Group ].Permissions[ tbl.id ] = true
		end
	end

	--[[if anus.unloadedPlugins[ tbl.id ] then
		print( "Unloaded plugin: " .. tbl.id )
		return
	end]]

	anus.getPlugins()[ tbl.id ] = anus.getPlugins()[ tbl.id ] or tbl
	local PluginData = anus.getPlugins()[ tbl.id ]
	PluginData.Filename = ANUS_FILENAME or "#ERROR"
	PluginData.FilenameStripped = ANUS_FILENAMESTRIPPED or "#ERROR"
	PluginData.description = PluginData.description or "No description."

	PluginData.argsAsString = ""
	local PluginData_OptArgCache = {}
	for k,v in next, PluginData.optionalarguments or {} do
		PluginData_OptArgCache[ v ] = true
	end
	for k,v in next, PluginData.arguments or {} do
		--[[for a,b in next, v do
			local isrequired = a == "required"
			anus.getPlugins()[ tbl.id ].argsAsString = anus.getPlugins()[ tbl.id ].argsAsString .. " " .. (isrequired and "<" or "[") .. "" .. b[ 1 ] .. ":" .. b[ 2 ] .. "" .. (isrequired and ">" or "]")
		end]]
		if not PluginData.optionalarguments or #PluginData.optionalarguments == 0 then
			for a,b in next, v do
				if not isstring( a ) then continue end

				PluginData.argsAsString = PluginData.argsAsString .. " <" .. b .. ":" .. a .. ">"
			end
		else
			for a,b in next, v do
				if not isstring( a ) then continue end
				local IsRequired = PluginData_OptArgCache[ a ] == nil

				PluginData.argsAsString = PluginData.argsAsString .. " " .. (isrequired and "<" or "[") .. "" .. b .. ":" .. a .. "" .. (IsRequired and ">" or "]")
			end
		end
	end

	if tbl.hasDataFolder then
		file.CreateDir( "anus/plugins/" .. tbl.id )
	end

	if anus.unloadedPlugins[ tbl.id ] then
		print( "ANUS unloaded plugin: " .. tbl.id )
		anus.getPlugins()[ tbl.id ].disabled = true
		return
	end

		-- moved up
	--[[if anus.CountGroupsAccess( tbl.id ) == 0 then
		local group = tbl.defaultAccess
		if not anus.Groups[ group ] then group = "user" end

		anus.Groups[ group ].Permissions = anus.Groups[ group ].Permissions or {}
		anus.Groups[ group ].Permissions[ tbl.id ] = true
	end]]

	if not tbl.notRunnable then
		anus.addCommand( tbl )
	end

	--anus.pluginLoad( tbl )

	--anus.registerPluginHooks( tbl )

end

function anus.loadPlugins( dir, filename )
	if SERVER and not ANUSGROUPSLOADED then return end

	local Files, Dirs = file.Find( "anus/plugins/*.lua", "LUA" )

		-- maybe add support for loading and unloading here later
		-- still not sure if i want to support this anyways
	if not filename then

		for k,v in next, Dirs do
			local Files2,Dirs2 = file.Find( "anus/plugins/" .. v .."/*.lua", "LUA" )

			for a,b in next, Files2 do
				if b == "sh_" .. v .. ".lua" then
					ANUS_FILENAME = b:lower()
					ANUS_FILENAMESTRIPPED = string.sub( ANUS_FILENAME, 1, -(#string.GetExtensionFromFilename( ANUS_FILENAME ) + 2) )
					if SERVER then
						include( "anus/plugins/" .. v .. "/" .. b )
						AddCSLuaFile( "anus/plugins/" .. v .. "/" .. b )
					else
						include( "anus/plugins/" .. v .. "/" .. b )
					end
				elseif b == "sv_" .. v .. ".lua" then
					if SERVER then
						include( "anus/plugins/" .. v .. "/" .. b )
					else
						include( "anus/plugins/" .. v .. "/" .. b )
					end
				elseif b == "cl_" .. v .. ".lua" then
					AddCSLuaFile( "anus/plugins/" .. v .. "/" .. b )
					if CLIENT then
						include( "anus/plugins/" .. v .. "/" .. b )
					end
				else
					if SERVER then
						AddCSLuaFile( "anus/plugins/" .. v .. "/" .. b )
					else
						include( "anus/plugins/" .. v .. "/" .. b )
					end
				end
			end
		end
	end

	for _,v in next, Files or {} do
		ANUS_FILENAME = v:lower()
		ANUS_FILENAMESTRIPPED = string.sub( ANUS_FILENAME, 1, -(#string.GetExtensionFromFilename( ANUS_FILENAME ) + 2) )

		if filename and v == filename then

			if string.sub( v, 1, 3 ) == "cl_" and CLIENT then
				include( "anus/plugins/" .. v )
			elseif string.sub( v, 1, 3 ) != "cl_" then
				include( "anus/plugins/" .. v )
			end

			if SERVER and string.sub( v, 1, 3 ) != "sv_" then
				AddCSLuaFile( "anus/plugins/" .. v )
			end

		else

			if string.sub( v, 1, 3 ) == "cl_" and CLIENT then
				include( "anus/plugins/" .. v )
			elseif string.sub( v, 1, 3 ) != "cl_" then
				include( "anus/plugins/" .. v )
			end

			if SERVER and string.sub( v, 1, 3 ) != "sv_" then
				AddCSLuaFile( "anus/plugins/" .. v )
			end
		end
	end
end
hook.Add( "anus_SVGroupsLoaded", "RunLoadPlugins", anus.loadPlugins )

function anus.getPlugins()
	return anus.pluginsTable
end

function anus.getPlugin( plugin )
	return anus.getPlugins()[ plugin ]
end

function anus.isPluginDisabled( plugin )
	return anus.getPlugins()[ plugin ] and anus.getPlugins()[ plugin ].disabled
end

	-- move to playerdata_sv
/*util.AddNetworkString( "anus_broadcastplugins" )

function anusBroadcastPlugins( pl )
	local Output = {}
	--[[for k,v in next, anus.getPlugins() do
		output[ k ] = 1
	end]]
	for k,v in next, anus.unloadedPlugins or {} do
		Output[ k ] = 0
	end

	net.Start( "anus_broadcastplugins" )
		net.WriteUInt( table.Count( Output ), 8 )
		for k,v in next, Output do
			net.WriteString( k )
			net.WriteBit( v == 1 and true or false )
		end
	net.Send( pl )
end*/


	-- make this local afterwards
function anus_savePlugins()
	local Data = von.serialize( anus.unloadedPlugins )

	file.Write( "anus/plugins.txt", Data )
end

function anus.pluginLoad( plugin, path )
	local Copy
	if SERVER then
		Copy = anus.unloadedPlugins[ plugin ]
		if not Copy then
			Error( "Plugin was not handling filename correctly\nPerhaps it is already enabled?\n" )
				-- why the fuck do i have to return here
			return
		end
	else
		Copy = path
	end

	anus.unloadedPlugins[ plugin ] = nil

	--anus.LoadPlugins( nil, copy )
	if not anus.getPlugins()[ plugin ].notRunnable then
		anus.addCommand( anus.getPlugins()[ plugin ] )
	end

	anus.getPlugins()[ plugin ].disabled = false

	if anus.getPlugins()[ plugin ].OnLoad then
		anus.getPlugins()[ plugin ].OnLoad()
	end
	
		-- only supports players and is ugly.
	local RunOnLoad = {}
	for k,v in next, anus.Hooks do
		for key, value in next, v do
			if value.pluginid == plugin and value.runonload then
				RunOnLoad[ k ] = {}
				RunOnLoad[ k ][ key ] = true
			end
		end
	end

	local Plugins, Exists = anus.getAllPluginHooks( plugin )
	for k,v in next, Plugins do
		for key, value in next, v do
			anus.registerHook( k, key, value, plugin, true, RunOnLoad[ k ] and RunOnLoad[ k ][ key ] )
		end
	end

	if SERVER then
		anus_savePlugins()

		net.Start( "anus_plugins_receivedload" )
			net.WriteString( plugin )
			net.WriteString( Copy )
		net.Broadcast()

			-- eh
		--[[for k,v in next, player.GetAll() do
			anusSendPlayerPerms( v )
		end]]
	end

	hook.Call( "anus_PluginLoaded", nil, plugin )

	--anus.addCommand( plugin )

end

function anus.pluginUnload( plugin )
	local tbl, exists = anus.getActivePluginHooks( plugin )
	for k,v in next, tbl do
		for key, value in next, v do
			anus.unregisterHook( k, key, plugin, true )
		end
	end

	if not anus.getPlugins()[ plugin ] then return false end

	local PLUGIN = plugin
	anus.unloadedPlugins[ plugin ] = anus.getPlugins()[ plugin ].Filename

	if anus.getPlugins()[ plugin ].OnUnload then
		anus.getPlugins()[ plugin ].OnUnload()
	end

	--anus.getPlugins()[ plugin ] = nil
	anus.removeCommand( plugin )
	--anus.getPlugins()[ plugin ] = nil
	anus.getPlugins()[ plugin ].disabled = true

	if SERVER then
		anus_savePlugins()

		net.Start( "anus_plugins_receivedunload" )
			net.WriteString( plugin )
		net.Broadcast()
	end

	hook.Call( "anus_PluginUnloaded", nil, PLUGIN )

	return true
end


util.AddNetworkString( "anus_plugins_receivedunload" )
util.AddNetworkString( "anus_plugins_receivedload" )

hook.Add( "Initialize", "anus_GrabPluginInfo", function()
	if file.Exists( "anus/plugins.txt", "DATA" ) then
		local Plugins = von.deserialize( file.Read( "anus/plugins.txt", "DATA" ) )
		for k,v in next, Plugins do
			if v then
				anus.unloadedPlugins[ k ] = v
			end
		end
	end
end )

--[[

CVars / Access Tags

]]

	-- CVars
util.AddNetworkString( "anus_replicateCVar" )
util.AddNetworkString( "anus_newCVar" )
util.AddNetworkString( "anus_newAccessTag" )

anus.cvarsRegistered = anus.cvarsRegistered or {}

local function SendReplicableCVar( players, cvar, newValue )
	net.Start( "anus_replicateCVar" )
		net.WriteString( cvar )
		net.WriteString( newValue )
	net.Send( players )
end

function anus.registerCVar( id, strdefault, strdesc, defaultaccess )
	if not id or not isstring( id ) then
		error( "CVar was not given a string!" )
	end
	
	strdefault = strdefault or "0"
	strdesc = strdesc or ""
	defaultaccess = defaultaccess or "user"
	
	if CurTime() <= 1.2 then
		timer.Create( "reRegisterCVar" .. id, 1.2 - CurTime(), 1, function()
			anus.registerCVar( id, strdefault, strdesc, defaultaccess )
		end )
		return
	end
	
	local Formatted = id:gsub( " ", "_" )
	anus.cvarsRegistered[ Formatted ] = { old = id, description = strdesc, default = strdefault, current = strdefault }
	
	CreateConVar( "anus_" .. Formatted, strdefault, {FCVAR_ARCHIVE}, strdesc )
	cvars.AddChangeCallback( "anus_" .. Formatted, function( cvar, old, new )
		anus.cvarsRegistered[ cvar:sub( 6, #cvar ) ].current = new
		SendReplicableCVar( player.GetAll(), cvar:sub( 6, #cvar ), new )
	end )
	
	net.Start( "anus_newCVar" )
		net.WriteString( Formatted )
		net.WriteString( strdefault )
		net.WriteString( strdesc )
	net.Broadcast()
	
	for k,v in next, anus.Groups do
		if v.Permissions[ id ] then return end
	end
	
	if not anus.Groups[ defaultaccess ] then
		anus.createGroup( defaultaccess )
	end
	
	anus.Groups[ defaultaccess ].Permissions[ id:lower() ] = true
end

local function CreateNewCVars( pl )
	local DelayMulti = 0
	for k,v in next, anus.cvarsRegistered do
		DelayMulti = DelayMulti + 1
		timer.Simple( 0.01 * DelayMulti, function()
			net.Start( "anus_newCVar" )
				net.WriteString( k )
				net.WriteString( v.current )
				net.WriteString( v.description )
			net.Send( pl )
		end )
	end
end
hook.Add( "anus_PlayerFullyLoaded", "anus_RegisterNewCVars", CreateNewCVars )
	
concommand.Add( "anus_ChangeCVarSetting", function( pl, cmd, arg )
	local Cvar = tostring( arg[ 1 ] ):lower()
	local Value = arg[ 2 ]

	if not anus.cvarsRegistered[ Cvar ] or not Value then return end
	if anus.cvarsRegistered[ Cvar ].current == Value then return end 
	
	if not pl:hasAccess( Cvar )  then
		anus.notifyPlayer( pl, "You are not allowed to change this ConVar." )
		pl:ConCommand( "anus_" .. Cvar .. " " .. anus.cvarsRegistered[ Cvar ].current )
		return
	end

	RunConsoleCommand( "anus_" .. Cvar, Value )
	anus.serverLog( pl:Nick() .. " changed cvar setting anus_" .. Cvar .. " to " .. Value, true )
end )

anus.registerCVar( "logecho", "2", "0/1/2/3 - No notifications/Players see \"Someone\"/Players see admin id/Players see admin name", "superadmin" )

	-- Access Tags
anus.accessTags = {}

function anus.registerAccessTag( id, groups, description )
	if not id or not isstring( id ) then
		error( "Access tag was not given a string" )
	end
	
	id = id:lower()
	description = description or ""
	
	if CurTime() <= 1.2 then
		timer.Create( "reRegisterAcessTag" .. id, 1.2 - CurTime(), 1, function()
			anus.registerAccessTag( id, groups, description )
		end )
		return
	end
	
	anus.accessTags[ id ] = description
	for k,v in next, anus.Groups do
		if v.Permissions[ id ] then return end
	end
	
	groups = isstring( groups ) and { groups } or groups
	
	for _,group in ipairs( groups ) do
		if not anus.Groups[ group ] then
			anus.createGroup( group )
		end
	
		anus.Groups[ group ].Permissions[ id ] = true
	end

	timer.Create( "anus_TriggerGroupSaving", 1, 1, function()
		anus.saveGroups( true )
	end )
end

local function CreateNewAccessTags( pl )
	local DelayMulti = 0
	for k,v in next, anus.accessTags do
		DelayMulti = DelayMulti + 1
		timer.Simple( 0.01 * DelayMulti, function()
			net.Start( "anus_newAccessTag" )
				net.WriteString( k )
				net.WriteString( v )
			net.Send( pl )
		end )
	end
end
hook.Add( "anus_PlayerFullyLoaded", "anus_RegisterNewAccessTags", CreateNewAccessTags )

anus.registerAccessTag( "seeusergroups", { "trusted", "admin", "superadmin", "owner" }, "Allows this group to see other usergroups" )
anus.registerAccessTag( "seeanonymousEchoes", { "admin", "superadmin", "owner" }, "Allows this group to see anonymous echoes" )
anus.registerAccessTag( "seesilentEchoes", "owner", "Allows this group to see silent echoes" )