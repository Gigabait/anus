	-- todo : check for family sharing
local plugin = {}
plugin.id = "altcheck"
plugin.name = "Alt Checker"
plugin.author = "Shinycow"
plugin.usage = ""
plugin.help = "Checks player for alts on join"
plugin.example = ""
plugin.notRunnable = true
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, arg, t, cmd )
	net.Start( "anus_requestalt" )
	net.Send( t )
	
	t.ReceiveTime = CurTime() + 0.6
	timer.CreatePlayer( t, "anus_requestalt", t.ReceiveTime - CurTime(), 1, function()
		if not t.ReceivedAlt then
			anus.ServerLog( t:Nick() .. " did not send a receive for alt.", true )
		end
	end )
	
	for k,v in next, anus.Bans do
		if not v.ip then continue end
		
		if t:IPAddress() == v.ip then
			anus.ServerLog( t:Nick() .. " (" .. t:SteamID() .. ") is an alt of currently banned user " .. v.Name .. " (" .. k .. ")", true )
		end
	end
end

if SERVER then

	util.AddNetworkString( "anus_requestalt" )
	util.AddNetworkString( "anus_receivealt" )
	
	net.Receive( "anus_receivealt", function( len, pl )
		local res = net.ReadString()
		
		if res and res != "" and #res < 34 then
			pl.ReceivedAlt = true
		end
		
		if #res == 1 then return end
		
		anus.ServerLog( pl:Nick() .. " reported back an alt of " .. res, true )
	end )

else

	net.Receive( "anus_requestalt", function()
		local f = string.Explode( "\n", file.Read( "crc32.txt", "DATA" ) )
		
		net.Start( "anus_receivealt" )
			net.WriteString( f[ 1 ] or "." )
		net.SendToServer()
	end )
	
end

anus.RegisterPlugin( plugin )
if SERVER then
	anus.RegisterHook( "anus_PlayerAuthenticated", "altcheck", function( pl )
		anus.GetPlugins()[ "altcheck" ].OnRun( self, NULL, nil, pl, nil )
	end, plugin.id )
end