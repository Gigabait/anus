anus.Users = anus.Users or {}
anus.TempUsers = anus.TempUsers or {}

util.AddNetworkString( "anus_requestgroups" )
util.AddNetworkString( "anus_broadcastgroups" )
util.AddNetworkString( "anus_groups_editname" )

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


function anus.SaveGroups()
	file.Write( "anus/groups.txt", von.serialize( anus.Groups ) )
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
		local copy = table.Copy( anus.Groups )
		anus.Groups = von.deserialize( file.Read( "anus/groups.txt", "DATA" ) )
		table.Add( anus.Groups, copy )
	else
		timer.Create( "anus_firstrun", 2, 1, function()
			anus.SaveGroups()
		end )
	end
	
	ANUSGROUPSLOADED = true
	hook.Call( "anus_SVGroupsLoaded", nil )
end)

net.Receive( "anus_groups_editname", function( len, pl )
	if not pl:HasAccess( "addgroup" ) then print( ":(" )return end
	
	local groupid = net.ReadString()
	local name = net.ReadString()
	
	if not anus.Groups[ groupid ] then print(" wat" )return end
	
	print( groupid, name )
	
	anus.Groups[ groupid ][ "name" ] = name
	anus.SaveGroups()
	
	for k,v in next, player.GetAll() do
		--if anus.Groups[ v.UserGroup or "user" ][ "Permissions" ].addgroup then
		if v:HasAccess( "addgroup" ) then
			print( v:Nick() )
			anusBroadcastGroups( v )
		end
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