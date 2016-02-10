if SERVER then
	anus.Users = anus.Users or {}
	anus.TempUsers = anus.TempUsers or {}

	hook.Add("InitPostEntity", "anus_CacheUsers", function()
		if file.Exists("anus/users.txt", "DATA") then
			anus.Users = von.deserialize( file.Read("anus/users.txt", "DATA") )
			for k,v in pairs(anus.Users) do
				if v.time then
					anus.TempUsers[ k ] = {group = v.group, time = v.time}
				end
			end
		end
	end)
	
	if not timer.Exists("anus_refreshtemps") then
		timer.Create("anus_refreshtemps", 2, 0, function()
			for k,v in pairs(player.GetAll()) do
				if anus.TempUsers[ v:SteamID() ] then
					if os.time() >= anus.TempUsers[ v:SteamID() ].time then
						for a,b in pairs(player.GetAll()) do
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
end