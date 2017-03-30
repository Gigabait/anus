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

local plugin = {}
plugin.id = "disorient"
plugin.chatcommand = { "!disorient" }
plugin.name = "Disorient"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" },
	{ Time = "number" }
}
plugin.optionalarguments =
{
	"Time"
}
plugin.description = "Disorients a player"
plugin.category = "Fun"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target )
	--local exempt = {}
	for k,v in ipairs( target ) do
		--[[if not caller:isGreaterOrEqualTo( v ) then
			exempt[ #exempt + 1 ] = v
			target[ k ] = nil
			continue
		end]]
			
		disorientPlayer( v )
	end

	--if #exempt > 0 then anus.playerNotification( caller, "Couldn't disorient ", exempt ) end
	--if #target == 0 then return end
	anus.notifyPlugin( caller, plugin.id, "disoriented ", target )
end

function plugin:OnUnload()
	for k,v in ipairs( player.GetAll() ) do
		disorientPlayer( v, true )
	end
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
anus.registerHook( "StartCommand", "disorient", function( pl, cmd )
	if CLIENT and pl.AnusDisoriented then
		for k,v in next, cmdInverse do
			if cmd:KeyDown( k ) then
				local action = cmdInverse[ k ][ 1 ]
				action( cmd, cmdInverse[ k ][ 2 ] )
			end
		end
	end
end, plugin.id )
anus.registerHook( "SetupMove", "disorient", function( pl, mv, cmd )
	if pl.AnusDisoriented then
		for k,v in next, mvInverse do
			if mv:KeyDown( k ) then
				local action = mvInverse[ k ][ 1 ]
				action( mv, mvInverse[ k ][ 2 ] )
			end
		end
	end
end, plugin.id )
if CLIENT then
	anus.registerHook( "player_spawn", "disorient", function( data )
		if Player( data.userid ) == LocalPlayer() then
			timer.Create( "Reinitialize_disorient", 0.1, 1, function()
				if LocalPlayer().AnusDisoriented then
					local eyes = LocalPlayer():EyeAngles()
					LocalPlayer():SetEyeAngles( Angle( eyes.p, eyes.y, 180 ) )
				end
			end )
		end
	end, plugin.id )
end



local plugin = {}
plugin.id = "reorient"
plugin.chatcommand = { "!reorient", "!orient", "!undisorient" }
plugin.name = "Reorient"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" }
}
plugin.description = "Reorients a player"
plugin.category = "Fun"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target )
	--local exempt = {}
	for k,v in ipairs( target ) do
		--[[if not caller:isGreaterOrEqualTo( v ) then
			exempt[ #exempt + 1 ] = v
			target[ k ] = nil
			continue
		end]]

		disorientPlayer( v, true )
	end

	--if #exempt > 0 then anus.playerNotification( caller, "Couldn't reorient ", exempt ) end
	--if #target == 0 then return end
	anus.notifyPlugin( caller, plugin.id, "reoriented ", target )
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