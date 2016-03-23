anus.Users = anus.Users or {}
anus.TempUsers = anus.TempUsers or {}

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
		anus.Groups = von.deserialize( file.Read( "anus/groups.txt", "DATA" ) )
	else
		timer.Create( "anus_firstrun", 2, 1, function()
			anus.SaveGroups()
		end )
	end
	
	ANUSGROUPSLOADED = true
	hook.Call( "anus_SVGroupsLoaded", nil )
end)

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