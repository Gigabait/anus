local plugin = {}
plugin.id = "gag"
plugin.chatcommand = { "!gag" }
plugin.name = "Gag"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" }
}
plugin.description = "Prevents a player from using their microphone"
plugin.category = "Communication"
plugin.defaultAccess = "admin"

if SERVER then
	util.AddNetworkString( "anus_gag" )
elseif CLIENT then
	net.Receive( "anus_gag", function()
		local pl = net.ReadEntity()
		local gag = tobool( net.ReadBit() )

		if gag and not pl:IsMuted() then
			pl:SetMuted( gag )
		elseif not gag and pl:IsMuted() then
			pl:SetMuted( gag )
		end
	end )
end

function plugin:OnRun( caller, target )
	--local exempt = {}
	for k,v in ipairs( target ) do
		--[[if not caller:isGreaterThan( v ) and caller != v then
			exempt[ #exempt + 1 ] = v
			target[ k ] = nil
			continue
		end]]

		net.Start("anus_gag")
			net.WriteEntity( v )
			net.WriteBit( true )
		net.SendOmit( v )
	end

	--if #exempt > 0 then anus.playerNotification( caller, "Couldn't gag ", exempt ) end
	--if #target == 0 then return end
	anus.notifyPlugin( caller, plugin.id, "gagged ", target )
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	parent:AddOption( self.name, function()
		local runtype = "\"" .. target:Nick() .. "\""

		pl:ConCommand( "anus " .. self.id .. " " .. runtype )
	end )
end
anus.registerPlugin( plugin )

local plugin = {}
plugin.id = "ungag"
plugin.chatcommand = { "!ungag" }
plugin.name = "Ungag"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" }
}
plugin.description = "Allows a player to use their microphone"
plugin.category = "Communication"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target )
	--local exempt = {}
	for k,v in ipairs( target ) do
	--[[	if not caller:isGreaterOrEqualTo( v ) then
			exempt[ #exempt + 1 ] = v
			target[ k ] = nil
			continue
		end]]

		net.Start( "anus_gag" )
			net.WriteEntity( v )
			net.WriteBit( false )
		net.SendOmit( v )
	end

	--if #exempt > 0 then anus.playerNotification( caller, "Couldn't ungag ", exempt ) end
	--if #target == 0 then return end
	anus.notifyPlugin( caller, plugin.id, "ungagged ", target )
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	parent:AddOption( self.name, function()
		local runtype = "\"" .. target:Nick() .. "\""

		pl:ConCommand( "anus " .. self.id .. " " .. runtype )
	end )
end
anus.registerPlugin( plugin )