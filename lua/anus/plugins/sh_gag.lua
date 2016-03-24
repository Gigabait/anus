local plugin = {}
plugin.id = "gag"
plugin.name = "Gag"
plugin.author = "Shinycow"
plugin.usage = "[player:Player]"
plugin.help = "Prevents a player from using their microphone"
plugin.category = "Chatting"
	-- chat command optional
plugin.chatcommand = "gag"
plugin.defaultAccess = "admin"

if SERVER then
	util.AddNetworkString("anus_gag")
elseif CLIENT then
	net.Receive( "anus_gag", function()
		local pl = net.ReadEntity()
		local gag = net.ReadBit()
	
		pl:SetMuted( gag )
	end )
end

function plugin:OnRun( pl, args, target )
	if not target and IsValid( pl ) then
		target = pl
	end

	if type(target) == "table" then

		for k,v in pairs(target) do
			if not pl:IsGreaterOrEqualTo( v ) then
				pl:ChatPrint("Sorry, you can't target " .. v:Nick())
				continue
			end

			net.Start("anus_gag")
				net.WriteEntity( v )
				net.WriteBit( true )
			net.SendOmit( v )
		end

		anus.NotifyPlugin( pl, plugin.id, color_white, "gagged ", anus.StartPlayerList, target, anus.EndPlayerList )

	else

		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint("Sorry, you can't target " .. target:Nick())
			return
		end

		anus.NotifyPlugin( pl, plugin.id, color_white, "gagged ", target )

		net.Start("anus_gag")
			net.WriteEntity( target )
			net.WriteBit( true )
		net.SendOmit( target )

	end
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	parent:AddOption( self.name, function()
		local runtype = target:SteamID()
		if target:IsBot() then runtype = target:Nick() end

		pl:ConCommand( "anus " .. self.chatcommand .. " " .. runtype )
	end )
end
anus.RegisterPlugin( plugin )

local plugin = {}
plugin.id = "ungag"
plugin.name = "Ungag"
plugin.author = "Shinycow"
plugin.usage = "[player:Player]"
plugin.help = "Allows a player to use their microphone"
plugin.category = "Chatting"
	-- chat command optional
plugin.chatcommand = "ungag"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, args, target )
	if not target and IsValid( pl ) then
		target = pl
	end

	if type(target) == "table" then

		for k,v in pairs(target) do
			if not pl:IsGreaterOrEqualTo( v ) then
				pl:ChatPrint("Sorry, you can't target " .. v:Nick())
				continue
			end

			net.Start("anus_gag")
				net.WriteEntity( v )
				net.WriteBit( false )
			net.SendOmit( v )
		end

		anus.NotifyPlugin( pl, plugin.id, color_white, "ungagged ", anus.StartPlayerList, target, anus.EndPlayerList )

	else

		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint("Sorry, you can't target " .. target:Nick())
			return
		end

		anus.NotifyPlugin( pl, plugin.id, color_white, "ungagged ", target )

		net.Start("anus_gag")
			net.WriteEntity( target )
			net.WriteBit( false )
		net.SendOmit( target )

	end
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	parent:AddOption( self.name, function()
		local runtype = target:SteamID()
		if target:IsBot() then runtype = target:Nick() end

		pl:ConCommand( "anus " .. self.chatcommand .. " " .. runtype )
	end )
end
anus.RegisterPlugin( plugin )