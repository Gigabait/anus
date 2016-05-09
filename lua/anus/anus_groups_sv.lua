anus.Users = anus.Users or {}
anus.TempUsers = anus.TempUsers or {}

util.AddNetworkString( "anus_requestgroups" )
util.AddNetworkString( "anus_broadcastgroups" )
util.AddNetworkString( "anus_groups_editid" )

function anusBroadcastGroups( pl )
	--[[net.Start("anus_broadcastgroups")
		net.WriteUInt( table.Count(anus.Groups), 8 )
		for k,v in next, anus.Groups do
			net.WriteString( k )
			net.WriteString( v.name )
			net.WriteUInt( table.Count( v.Permissions ), 8 )
			for a,b in next, v.Permissions do
				net.WriteString( a )
				net.WriteString
			net.WriteString( v.time )
			net.WriteString( v.admin )
			net.WriteString( v.admin_steamid )
		end
	net.Send( pl )]]
	
	net.Start( "anus_broadcastgroups" )
		net.WriteTable( anus.Groups )
	net.Send( pl )
end
net.Receive( "anus_requestgroups" , function( len, pl )
	if not pl:HasAccess( "addgroup" ) then return end
	
	anusBroadcastGroups( pl )
end)


function anus.SaveGroups( bBroadcast )
	file.Write( "anus/groups.txt", von.serialize( anus.Groups ) )
	if bBroadcast then
		for k,v in next, player.GetAll() do
			anusBroadcastGroups( v )
		end
	end
end

hook.Add("Initialize", "anus_GrabDataInfo", function()
	if file.Exists( "anus/users.txt", "DATA" ) then
		anus.Users = von.deserialize( file.Read( "anus/users.txt", "DATA" ) )
		for k,v in next, anus.Users do
			if v.time then
				anus.TempUsers[ k ] = {group = v.group, time = v.time}
			end
		end
	end

	if file.Exists( "anus/groups.txt", "DATA" ) then
		anus.Groups = von.deserialize( file.Read( "anus/groups.txt", "DATA" ) )
		for k,v in next, anus.GroupPluginCache do
			local group = k
			if not anus.Groups[ group ] then group = "user" end
			if not anus.Groups[ group ] then
				Error( "User group has been deleted! Remove data/anus/groups.txt and start over.\n" )
				return
			end
			
			for key, value in next, v do
				if not anus.Groups[ group ].Permissions[ key ] then
					anus.Groups[ group ].Permissions[ key ] = true
				end
			end
		end
	else
		timer.Create( "anus_firstrun", 2, 1, function()
			anus.SaveGroups()
		end )
	end
	
	ANUSGROUPSLOADED = true
	hook.Call( "anus_SVGroupsLoaded", nil )
end)


function anus.ChangeGroupName( group, name )
	if not anus.Groups[ group ] then return false, "Incorrect group supplied" end
	if #name > 28 then return false, "Name is too long" end
	local foundchar = false
	for i=1,#name do
		if name[ i ] != " " then
			foundchar = true
			break
		end
	end
	if not foundchar then return false, "Supply a valid name" end
	
	anus.Groups[ group ][ "name" ] = name
	anus.SaveGroups( true )
	
	return true
end

function anus.ChangeGroupID( group, id )
	if not anus.Groups[ group ] then return false end
	if anus.Groups[ group ].hardcoded then return false end
	if anus.Groups[ id ] then error( "Group id " .. id .. " already exists!" ) return false end
	
	local tbl = anus.GetGroupDirectInheritance( group )
	anus.Groups[ id ] = table.Copy( anus.Groups[ group ] )
	anus.Groups[ group ] = nil
	
	for k,v in next, tbl do
		anus.Groups[ v ].Inheritance = id
	end
	anus.SaveGroups( true )
	
	for k,v in next, anus.Users do
		if v.group == group then
			v.group = id
		end
	end
	file.Write( "anus/users.txt", von.serialize( anus.Users ) )
	
	for k,v in next, player.GetAll() do
		if v:IsAnusSendable() then
			anusBroadcastUsers( v )
		end
	end
	
	return true
end

net.Receive( "anus_groups_editid", function( len, pl )
	if not pl:HasAccess( "addgroup" ) then return end
	
	local groupid = net.ReadString()
	local id = net.ReadString()
	
	local changed = anus.ChangeGroupID( groupid, id )
	
	if changed then
		anus.ServerLog( pl:Nick() .. " (" .. pl:SteamID() .. ") changed group id \"" .. groupid .. "\" to \"" .. id .. "\"" )
	end
end )

if not timer.Exists("anus_refreshtemps") then
	timer.Create("anus_refreshtemps", 2, 0, function()
		for k,v in next, player.GetAll() do
			if anus.TempUsers[ v:SteamID() ] then
				if os.time() >= anus.TempUsers[ v:SteamID() ].time then
					for a,b in next, player.GetAll() do
						chat.AddText( b, team.GetColor(v:Team()), v:Nick(), color_white, " time for ", Color( 180,180,255, 255 ), anus.TempUsers[ v:SteamID() ].group, color_white, " has expired and has been demoted." )
					end
					anus.Users[ v:SteamID() ] = nil
					anus.TempUsers[ v:SteamID() ] = nil
					v:SetUserGroup( "user" )
					file.Write( "anus/users.txt", von.serialize(anus.Users) )
				end
			end
		end
	end)
end