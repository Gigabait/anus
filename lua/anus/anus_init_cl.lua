anus_MainMenu = anus_MainMenu or nil
 
hook.Add( "OnReloaded", "anus_closemenus", function()
	if IsValid( anus_MainMenu ) then
		anus_MainMenu:Remove()
		anus_MainMenu = nil
	end
end )

anus.PlayerDC = anus.PlayerDC or {}
net.Receive( "anus_broadcastdc", function()
	anus.PlayerDC = {}
	
	local amt = net.ReadUInt( 16 )
	local server_hour = net.ReadUInt( 6 )
	for i=1,amt do
		anus.PlayerDC[ net.ReadString() ] = { name = net.ReadString(), kills = net.ReadUInt( 16 ), hour = net.ReadUInt( 6 ), minute = net.ReadUInt( 8 ), second = net.ReadUInt( 8 ) }
	end
	
	anus.ServerHour = server_hour
end )

anus.Users = anus.Users or {}
net.Receive( "anus_broadcastusers", function()
	anus.Users = {}
	anus.TempUsers = {}
	
	local amt = net.ReadUInt( 8 )
	for i=1,amt do
		local group = net.ReadString()
		local steamid = net.ReadString()
		local name = net.ReadString()
		local time = net.ReadString()
		anus.Users[ group ] = anus.Users[ group ] or {}
		anus.Users[ group ][ steamid ] = { name = name, time = time }
		if time != "0" then
			anus.TempUsers[ steamid ] = { group = group, name = name, time = time }
		end

		steamworks.RequestPlayerInfo( util.SteamIDTo64( steamid ) ) 
	end
	
	hook.Call( "OnPlayerGroupsChanged" )
end )

concommand.Add( "+anus_menu", function( pl )
	if IsValid( anus_MainMenu ) then
		anus_MainMenu:Remove()
		anus_MainMenu = nil
	else
		anus_MainMenu = vgui.Create( "anus_mainmenu" )
	end
end )

concommand.Add( "-anus_menu", function( pl )
	if IsValid( anus_MainMenu ) then
		anus_MainMenu:Remove()
		anus_MainMenu = nil
		
		if IsValid( anus_qkick_menu ) then
			anus_qkick_menu:Remove()
			anus_qkick_menu = nil
		end
		if IsValid( anus_qban_menu ) then
			anus_qban_menu:Remove()
			anus_qban_menu = nil
		end
		
		gui.EnableScreenClicker( false )
	end
end )

concommand.Add( "anus_menu", function( pl )
	if IsValid( anus_MainMenu ) then
		anus_MainMenu:Remove()
		anus_MainMenu = nil
		
		if IsValid( anus_qkick_menu ) then
			anus_qkick_menu:Remove()
			anus_qkick_menu = nil
		end
		if IsValid( anus_qban_menu ) then
			anus_qban_menu:Remove()
			anus_qban_menu = nil
		end
		
		gui.EnableScreenClicker( false )
	else
		anus_MainMenu = vgui.Create( "anus_mainmenu" )
	end
end)

hook.Add( "ChatText", "anus_RemoveKickBan", function( index, name, text, type )
	if type == "joinleave" and string.find( text, "Check console" ) then
		return true
	end
end )

hook.Add( "OnPlayerGroupsChanged", "anus_RequestBans", function()
	net.Start( "anus_requestbans" )
	net.SendToServer()
end )