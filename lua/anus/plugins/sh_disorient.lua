	-- should probably just use CalcView
	-- this may mess with other addons/scripts ?
if SERVER then
	util.AddNetworkString( "anus_disoriented" )
end

function disorientPlayer( pl, bReorient )
	if not SERVER then return end

	if not bReorient then
		local eyes = pl:EyeAngles()
		pl:SetEyeAngles( Angle( eyes.p, eyes.y, 180 ) )
		
		pl.AnusDisoriented = true
		net.Start( "anus_disoriented" )
			net.WriteBool( true )
		net.Send( pl )
	else
		local eyes = pl:EyeAngles()
		pl:SetEyeAngles( Angle( eyes.p, eyes.y, 0 ) )

		pl.AnusDisoriented = false
		net.Start( "anus_disoriented" )
			net.WriteBool( false )
		net.Send( pl )
	end
end

if CLIENT then
	net.Receive( "anus_disoriented", function()
		local bDisoriented = net.ReadBool()
		
		LocalPlayer().AnusDisoriented = bDisoriented
	end )
	
	gameevent.Listen( "player_spawn" )
	hook.Add( "player_spawn", "anus_plugins_disorient", function( data )
		if Player( data.userid ) == LocalPlayer() then
			timer.Create( "Reinitialize_disorient", 0.1, 1, function()
				if LocalPlayer().AnusDisoriented then
					local eyes = LocalPlayer():EyeAngles()
					LocalPlayer():SetEyeAngles( Angle( eyes.p, eyes.y, 180 ) )
				end
			end )
		end
	end )
end

local mvInverse =
{
[ IN_FORWARD ] = { FindMetaTable( "CMoveData" ).SetForwardSpeed, -999 },
[ IN_BACK ] = { FindMetaTable( "CMoveData" ).SetForwardSpeed, 999 },
[ IN_MOVELEFT ] = { FindMetaTable( "CMoveData" ).SetSideSpeed, 999 },
[ IN_MOVERIGHT ] = { FindMetaTable( "CMoveData" ).SetSideSpeed, -999 },
}
local cmdInverse = 
{
[ IN_FORWARD ] = { FindMetaTable( "CUserCmd" ).SetForwardMove, -999 },
[ IN_BACK ] = { FindMetaTable( "CUserCmd" ).SetForwardMove, 999 },
[ IN_MOVELEFT ] = { FindMetaTable( "CUserCmd" ).SetSideMove, 999 },
[ IN_MOVERIGHT ] = { FindMetaTable( "CUserCmd" ).SetSideMove, -999 },
}
hook.Add( "StartCommand", "anus_plugins_disorient", function( pl, cmd )
	if CLIENT and pl.AnusDisoriented then
		for k,v in next, cmdInverse do
			if cmd:KeyDown( k ) then
				local action = cmdInverse[ k ][ 1 ]
				action( cmd, cmdInverse[ k ][ 2 ] )
			end
		end
	end
end )

hook.Add( "SetupMove", "anus_plugins_disorient", function( pl, mv, cmd )
	if pl.AnusDisoriented then
		for k,v in next, mvInverse do
			if mv:KeyDown( k ) then
				local action = mvInverse[ k ][ 1 ]
				action( mv, mvInverse[ k ][ 2 ] )
			end
		end
	end
end )

local plugin = {}
plugin.id = "disorient"
plugin.name = "Disorient"
plugin.author = "Shinycow"
plugin.usage = "<player:Player> [string:Time]"
plugin.help = "Disorients a player"
plugin.example = "!disorient bot 30s"
plugin.category = "Fun"
plugin.chatcommand = "disorient"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, args, target )

	if not target and IsValid( pl ) then
		target = pl
	end
		
	if type( target ) == "table" then
	
		for k,v in next, target do
			if not pl:IsGreaterOrEqualTo( v ) then
				pl:ChatPrint( "Sorry, you can't target " .. v:Nick() )
				target[ k ] = nil
				continue
			end
			
			disorientPlayer( v )
		end
		
		anus.NotifyPlugin( pl, plugin.id, color_white, "disoriented ", anus.StartPlayerList, target, anus.EndPlayerList )
	
	else
		
		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint( "Sorry, you can't target " .. target:Nick() )
			return
		end
		
		disorientPlayer( target )
		
		anus.NotifyPlugin( pl, plugin.id, color_white, "disoriented ", target )
	
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
plugin.id = "reorient"
plugin.name = "Reorient"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>"
plugin.help = "Reorients a player"
plugin.example = "!reorient bot"
plugin.category = "Fun"
plugin.chatcommand = "reorient"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, args, target )

	if not target and IsValid( pl ) then
		target = pl
	end
		
	if type( target ) == "table" then
	
		for k,v in next, target do
			if not pl:IsGreaterOrEqualTo( v ) then
				pl:ChatPrint( "Sorry, you can't target " .. v:Nick() )
				target[ k ] = nil
				continue
			end
			
			disorientPlayer( v, true )
		end
		
		anus.NotifyPlugin( pl, plugin.id, color_white, "reoriented ", anus.StartPlayerList, target, anus.EndPlayerList )
	
	else
		
		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint( "Sorry, you can't target " .. target:Nick() )
			return
		end
		
		disorientPlayer( target, true )
		
		anus.NotifyPlugin( pl, plugin.id, color_white, "reoriented ", target )
	
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