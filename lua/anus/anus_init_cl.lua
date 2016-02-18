anus_MainMenu = anus_MainMenu or nil

hook.Add("OnReloaded", "anus_closemenus", function()
	if IsValid(anus_MainMenu) then
		anus_MainMenu:Remove()
		anus_MainMenu = nil
	end
end)

anus.PlayerDC = anus.PlayerDC or {}
net.Receive("anus_broadcastdc", function()
	anus.PlayerDC = {}
	
	local amt = net.ReadUInt( 16 )
	local server_hour = net.ReadUInt( 6 )
	for i=1,amt do
		anus.PlayerDC[ net.ReadString() ] = {name = net.ReadString(), kills = net.ReadUInt( 16 ), hour = net.ReadUInt( 6 ), minute = net.ReadUInt( 8 ), second = net.ReadUInt( 8 )}
	end
	
	anus.ServerHour = server_hour
end)

anus.Users = anus.Users or {}
net.Receive("anus_broadcastusers", function()
	anus.Users = {}
	
	local amt = net.ReadUInt( 8 )
	for i=1,amt do
		--print(i)
		local group = net.ReadString()
		anus.Users[ group ] = anus.Users[ group ] or {}
		local steamid = net.ReadString()
		anus.Users[ group ][ steamid ] = {name = net.ReadString()}

		steamworks.RequestPlayerInfo( util.SteamIDTo64( steamid ) ) 
	end
	
	hook.Call("OnPlayerGroupsChanged")
end)

concommand.Add("+anus_menu", function( pl )
	if IsValid(anus_MainMenu) then
		anus_MainMenu:Remove()
		anus_MainMenu = nil
	else
		anus_MainMenu = vgui.Create("anus_mainmenu")
	end
end)

concommand.Add("-anus_menu", function( pl )
	if IsValid(anus_MainMenu) then
		anus_MainMenu:Remove()
		anus_MainMenu = nil
		
		if IsValid(anus_qkick_menu) then
			anus_qkick_menu:Remove()
			anus_qkick_menu = nil
		end
		if IsValid(anus_qban_menu) then
			anus_qban_menu:Remove()
			anus_qban_menu = nil
		end
		
		gui.EnableScreenClicker( false )
	end
end)

concommand.Add("anus_menu", function( pl )
	if IsValid(anus_MainMenu) then
		anus_MainMenu:Remove()
		anus_MainMenu = nil
		
		if IsValid(anus_qkick_menu) then
			anus_qkick_menu:Remove()
			anus_qkick_menu = nil
		end
		if IsValid(anus_qban_menu) then
			anus_qban_menu:Remove()
			anus_qban_menu = nil
		end
		
		gui.EnableScreenClicker( false )
	else
		anus_MainMenu = vgui.Create("anus_mainmenu")
	end
end)

concommand.Add("anus_menu_new", function( pl )
	if IsValid(anus_MainMenuNew) then
		anus_MainMenuNew:Remove()
		anus_MainMenuNew = nil
		
		if IsValid(anus_qkick_menu) then
			anus_qkick_menu:Remove()
			anus_qkick_menu = nil
		end
		if IsValid(anus_qban_menu) then
			anus_qban_menu:Remove()
			anus_qban_menu = nil
		end
		
		gui.EnableScreenClicker( false )
	else
		anus_MainMenuNew = vgui.Create("anus_mainmenu_new")
	end
end)

hook.Add("ChatText", "anus_RemoveKickBan", function( index, name, text, type )
	if type == "joinleave" and string.find(text, "Check console") then
		return true
	end
end)