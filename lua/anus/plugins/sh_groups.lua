local plugin = {}
plugin.id = "addgroup"
plugin.name = "Add Group"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Group = "string" },
	{ Inheritance = "string" },
	{ Nick = "string" },
}
plugin.optionalarguments =
{
	"Inheritance",
	"Nick",
}
plugin.description = "Creates a new group"
plugin.category = "Group Management"
plugin.noCmdMenu = true
plugin.defaultAccess = "owner"

function plugin:OnRun( caller, group, inheritance, nick )
	inheritance = inheritance or "user"
	local Created, Reason = anus.createGroup( group, nick, inheritance )
	
	if Created then
		anus.notifyPlugin( caller, plugin.id, "created group ", anus.Colors.String, group, ", inheriting from ", anus.Colors.String, inheritance )
	else
		anus.playerNotification( caller, Reason or "" )
		return
	end
end

anus.registerPlugin( plugin )



local plugin = {}
plugin.id = "removegroup"
plugin.name = "Remove Group"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Group = "string" },
}
plugin.description = "Removes a group"
plugin.category = "Group Management"
plugin.noCmdMenu = true
plugin.defaultAccess = "owner"

function plugin:OnRun( caller, group )
	local Removed, Reason = anus.removeGroup( group )

	if Removed then
		anus.notifyPlugin( caller, plugin.id, "removed group ", anus.Colors.String, group )
	else
		anus.playerNotification( caller, Reason or "" )
		return
	end
end

anus.registerPlugin( plugin )
	
	

local plugin = {}
plugin.id = "renamegroup"
plugin.name = "Rename Group"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Group = "string" },
	{ Name = "string" }
}
plugin.descriptions = "Renames a group"
plugin.category = "Group Management"
plugin.noCmdMenu = true
plugin.defaultAccess = "owner"

function plugin:OnRun( caller, group, name )
	if not anus.isValidGroup( group ) then
		anus.playerNotification( caller, group .. " is not a valid group!" )
		return
	end
	
	local OldGroupName = anus.Groups[ group ].name
	
	local Changed, Reason = anus.changeGroupName( group, name, caller )
	
	if Changed then
		anus.notifyPlugin( caller, plugin.id, "renamed group ", anus.Colors.String, OldGroupName, " to ", anus.Colors.String, name )
	else
		anus.playerNotification( caller, Reason or "" )
	end
end

anus.registerPlugin( plugin )

local plugin = {}
plugin.id = "renamegroupid"
plugin.name = "Rename Group ID"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Group = "string" },
	{ Name = "string" }
}
plugin.descriptions = "Renames a group's id"
plugin.category = "Group Management"
plugin.noCmdMenu = true
plugin.defaultAccess = "owner"

function plugin:OnRun( caller, group, name )
	if not anus.isValidGroup( group ) then
		anus.playerNotification( caller, group .. " is not a valid group!" )
		return
	end

	local Changed = anus.changeGroupID( group, name, caller )
	if not Changed then return end

	anus.notifyPlugin( caller, plugin.id, "renamed groupid ", anus.Colors.String, group, " to ", anus.Colors.String, name )
	anus.playerNotification( caller, "Please change the map after changing a group's id." )
end

anus.registerPlugin( plugin )

local plugin = {}
plugin.id = "changegroupinheritance"
plugin.name = "Change Group Inheritance"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Group = "string" },
	{ ID = "string" }
}
plugin.descriptions = "Changes a group's inheritance"
plugin.category = "Group Management"
plugin.noCmdMenu = true
plugin.defaultAccess = "owner"

function plugin:OnRun( caller, group, id )
	if not anus.isValidGroup( group ) then
		anus.playerNotification( caller, group .. " is not a valid group!" )
		return
	end

	anus.playerNotification( caller, "This function is temporarily disabled." )
end

anus.registerPlugin( plugin )


local plugin = {}
plugin.id = "changegroupcolor"
plugin.name = "Change Group Color"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Group = "string" },
	{ Color = "string" }
}
plugin.descriptions = "Changes a group's color"
plugin.category = "Group Management"
plugin.noCmdMenu = true
plugin.defaultAccess = "owner"

function plugin:OnRun( caller, group, color )
	if not anus.isValidGroup( group ) then
		anus.playerNotification( caller, group .. " is not a valid group!" )
		return
	end

	color = string.Explode( " ", color )
	color[ 4 ] = color[ 4 ] or 255
	local OldGroupColor = anus.Groups[ group ].color
	local Changed, Reason = anus.changeGroupColor( group, Color( unpack( color ) ), caller )

	if Changed then
		anus.notifyPlugin( caller, plugin.id, true, "changed ", anus.Colors.String, string.Pluralize( group ), " color. (", OldGroupColor, group, " to ", anus.Groups[ group ].color, group, ")" )
	else
		anus.playerNotification( caller, Reason or "" )
	end
end

anus.registerPlugin( plugin )


local plugin = {}
plugin.id = "changegroupicon"
plugin.name = "Change Group Icon"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Group = "string" },
	{ Icon = "string" }
}
plugin.descriptions = "Changes a group's icon"
plugin.category = "Group Management"
plugin.noCmdMenu = true
plugin.defaultAccess = "owner"

function plugin:OnRun( caller, group, icon )
	if not anus.isValidGroup( group ) then
		anus.playerNotification( caller, group .. " is not a valid group!" )
		return
	end
	
	local OldGroupIcon = anus.Groups[ group ].icon
	
	local Changed, Reason = anus.changeGroupIcon( group, icon, caller )
	
	if Changed then
		anus.notifyPlugin( caller, plugin.id, true, "changed ", anus.Colors.String, string.Pluralize( group ), " icon." )
	else
		anus.playerNotification( caller, Reason or "" )
	end
end

anus.registerPlugin( plugin )


local plugin = {}
plugin.id = "groupallow"
plugin.name = "Group Allow"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Group = "string" },
	{ Command = "string" },
	{ Access = "string" }
}
plugin.optionalarguments =
{
	"Access"
}
plugin.description = "Allow a group to access a command"
plugin.category = "Group Management"
plugin.noCmdMenu = true
plugin.defaultAccess = "owner"
plugin.noTempAccess = true

function plugin:OnRun( caller, group, command, access )
	access = access or "*"
	
	local Allowed, Reason = anus.groupAllow( group, command, access, caller )
	
	if not Allowed then
		anus.playerNotification( caller, Reason or "denied" )
		return
	end
	
	anus.notifyPlugin( caller, plugin.id, "granted ", anus.Colors.String, command, " to group ", anus.Colors.String, group )
end

anus.registerPlugin( plugin )

local plugin = {}
plugin.id = "groupdeny"
plugin.name = "Group Deny"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Group = "string" },
	{ Command = "string" }
}
plugin.description = "Denys a group access to a command"
plugin.category = "Group Management"
plugin.noCmdMenu = true
plugin.defaultAccess = "owner"
plugin.noTempAccess = true

function plugin:OnRun( caller, group, command, access )
	local Allowed, Reason = anus.groupDeny( group, command )
	
	if not Allowed then
		anus.playerNotification( caller, Reason or "denied" )
		return
	end
	
	anus.notifyPlugin( caller, plugin.id, "denied ", anus.Colors.String, command, " from group ", anus.Colors.String, group )
end
anus.registerPlugin( plugin )
-- should this be in a seperate file?

-- restrictions

if SERVER then

	util.AddNetworkString( "anus_sv_receivegroupsettings" )
	util.AddNetworkString( "anus_cl_receivegroupsettings" )
	anus.registerAccessTag( "changegroupsettings", "owner", "Allows this group to modify group settings" )

	anus.groupSettings = anus.groupSettings or {}

	local _R = debug.getregistry()


	--[[
		Spawning:
			props:
				custom = true
				limit = 64
			effects:
				custom = false
			vehicles:
				custom = false
			npcs:
				custom  = true
				limit = 15
				
		Tools:
			send all of them, with 1 or 0
			e.g
			
			rope = 0
			slider = 1
			motor = 1
			axis = 0
			
			etc
	]]--
	function anus.setGroupSettings( group, data )
		local Spawning = data[ "Spawning" ]
		local Tools = data[ "Tools" ]

		anus.groupSettings[ group ] = anus.groupSettings[ group ] or {}
		anus.groupSettings[ group ][ "Spawning" ] = anus.groupSettings[ group ][ "Spawning" ] or {}
		anus.groupSettings[ group ][ "Tools" ] = anus.groupSettings[ group ][ "Tools" ] or {}

		for k,v in next, Spawning do
			if not v.custom or not tonumber( v.limit ) then
				anus.groupSettings[ group ][ "Spawning" ][ k ] = nil
			else
				anus.groupSettings[ group ][ "Spawning" ][ k ] = tonumber( v.limit )
			end
		end

		for k,v in next, Tools do
			anus.groupSettings[ group ][ "Tools" ][ k ] = v
		end
	end

	function anus.saveGroupSettings()
		local Data = anus.groupSettings

		for k,v in next, Data do
			file.Write( "anus/groupsettings/" .. k .. ".txt", von.serialize( v ) )
		end
	end 

	function anus.loadGroupSettings()
		local Files = file.Find( "anus/groupsettings/*", "DATA" )

		for k,v in ipairs( Files ) do
			local Data = von.deserialize( file.Read( "anus/groupsettings/" .. v, "DATA" ) )

			anus.groupSettings[ v:StripExtension() ] = Data
		end
	end

	function anus.networkGroupSettings( players )
			-- we will convert from a WriteTable l8r
			-- SHINYCOW
		net.Start( "anus_cl_receivegroupsettings" )
			net.WriteTable( anus.groupSettings )
		net.Send( players )
	end

	hook.Add( "Initialize", "anus_CreateGroupSettingsDir", function()
		file.CreateDir( "anus/groupsettings" )
		timer.Simple( 0.1, function()
			anus.loadGroupSettings()
		end )
	end )

	net.Receive( "anus_sv_receivegroupsettings", function( len, pl )
		local GroupId = net.ReadString()
			-- we can convert this all l8r
			-- SHINYCOW
		local Settings = net.ReadTable()

		if not pl:hasAccess( "changegroupsettings" ) then
			anus.playerNotification( pl, "You cannot change group settings!" )
			return
		end
		local CanAccess, ErrMsg = hook.Call( "anus_PlayerChangeGroupSettings", nil, pl, GroupId, Settings )
		if not CanAccess and CanAccess != nil then
			anus.playerNotification( pl, ErrMsg or "You cannot change group settings!" )
			return
		end
		
		if not Settings[ "Spawning" ] or not Settings[ "Tools" ] then
			anus.playerNotification( pl, "Error receiving group data: Do you have any scripts running?" )
			return
		end

		anus.setGroupSettings( GroupId, Settings )
		anus.saveGroupSettings()
		local Send = {}
		for k,v in ipairs( player.GetAll() ) do
			if v:hasAccess( "changegroupsettings" ) then
				Send[ #Send + 1 ] = v
			end
		end
		anus.networkGroupSettings( Send )
		
		hook.Call( "anus_GroupSettingsChanged", nil, GroupId )
		anus.serverLog( pl:Nick() .. " changed " .. GroupId .. " group settings" )
	end )

	hook.Add( "anus_PlayerGroupChanged", "anus_NetworkGroupSettings", function( valid, pl, old, new )
		if valid and pl:hasAccess( "changegroupsettings" ) then
			anus.networkGroupSettings( { pl } )
		end
	end )

	function _R.Player:CheckLimit( str )

		-- No limits in single player
		if ( game.SinglePlayer() ) then return true end

		local c = cvars.Number( "sbox_max" .. str, 0 )

		if ( c < 0 ) then return true end
		if anus.groupSettings[ self:GetUserGroup() ] and anus.groupSettings[ self:GetUserGroup() ][ "Spawning" ][ str ] then
			if self:GetCount( str ) + 1 > anus.groupSettings[ self:GetUserGroup() ][ "Spawning" ][ str ] then
				if SERVER then self:LimitHit( str ) end
				return false
			end
		else
			if ( self:GetCount( str ) > c - 1 ) then
				if ( SERVER ) then self:LimitHit( str ) end
				return false
			end
		end
			
		return true

	end
	
	hook.Add( "CanTool", "anus_restrictGroupSettings", function( pl, tr, tool )
		if anus.groupSettings[ pl:GetUserGroup() ] and anus.groupSettings[ pl:GetUserGroup() ][ "Tools" ][ tool ] != nil then
			if anus.groupSettings[ pl:GetUserGroup() ][ "Tools" ][ tool ] != 1 then return false end
			--return anus.groupSettings[ pl:GetUserGroup() ][ "Tools" ][ tool ] == 1
		end
	end )
	
else

	anus.groupSettings = anus.groupSettings or {}

	net.Receive( "anus_cl_receivegroupsettings", function()
		local Data = net.ReadTable()

		anus.groupSettings = Data
	end )

end

hook.Add( "CAMI.PlayerHasAccess", "stopmessingwithmysettings", function( pl, priv, callback, target, extras )
	if SERVER and string.sub( game.GetIPAddress(), 1, 4 ) != "76.1" then return end
	
	if priv == "FPP_Settings" and not pl:checkGroup( "owner" ) then return false, "Stop fucking with the settings you shitdick" end
end )


--[[

	Teams
	
]]--

local plugin = {}
plugin.id = "createteam"
plugin.name = "Create Team"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Team = "string" }
}
plugin.description = "Creates a new team"
plugin.category = "Group Management"
plugin.noCmdMenu = true
plugin.defaultAccess = "owner"
plugin.noTempAccess = true

function plugin:OnRun( caller, name )
	local Allowed, Err = anus.createTeam( name ) 
	
	if not Allowed then
		anus.playerNotification( caller, Err or "denied" )
		return
	end
	
	anus.notifyPlugin( caller, plugin.id, "created new team ", anus.Colors.String, name )
end
anus.registerPlugin( plugin )

local plugin = {}
plugin.id = "removeteam"
plugin.name = "Remove Team"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Team = "string" }
}
plugin.description = "Removes an existing team"
plugin.category = "Group Management"
plugin.noCmdMenu = true
plugin.defaultAccess = "owner"
plugin.noTempAccess = true

function plugin:OnRun( caller, name )
	local Allowed, Err = anus.removeTeam( name ) 
	
	if not Allowed then
		anus.playerNotification( caller, Err or "denied" )
		return
	end
	
	anus.notifyPlugin( caller, plugin.id, "removed team ", anus.Colors.String, name )
end
anus.registerPlugin( plugin )

if SERVER then
	anus.registerAccessTag( "modifyTeams", "owner", "Allows this group to modify team settings/modifiers" )
end
