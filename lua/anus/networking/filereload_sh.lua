if SERVER then
	util.AddNetworkString( "anus_FileReload" )
else
		-- plz dont be over 64KB. thx
	net.Receive( "anus_FileReload", function()
		local data = net.ReadString()

		RunString( data )
	end )
end