-- setmodelscale
-- 4 would be 4 times original
-- wont go off GetModelScale, that would cause confusion
-- just go off their spawned getmodelscale, then go upwards from there (or down)

local plugin = {}
plugin.id = "scale"
plugin.chatcommand = "!scale"
plugin.name = "Scale Player"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" },
	{ Scale = "number", 1 },
	{ Save = "boolean", false }
}
plugin.optionalarguments = 
{
	"Scale",
	"Save"
}
plugin.description = "Makes a player bigger / smaller"
plugin.example = "!scale ^ 3"
plugin.category = "Fun"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target, scale, save )
	scale = math.Clamp( scale, 0.2, 5 )
	local scale_overridexy = math.Clamp( scale, 0.8, 1.25 )--1.5625 )--1.875 )
	local scale_overridez = math.Clamp( scale, 0.05, 1.125 )
	
	--local exempt = {}
	for k,v in ipairs( target ) do
		--[[if not caller:isGreaterOrEqualTo( v ) then
			exempt[ #exempt + 1 ] = v
			target[ k ] = nil
			continue
		end]]
				
		v:SetModelScale( scale, 0.65 )
		local hullmin, hullmax = v:GetHull()
		--hullmin.x, hullmin.y = -16 / ( 1 / scale ), -16 / ( 1 / scale )
		--hullmax.x, hullmax.y, hullmax.z = 16 / ( 1 / scale ), 16 / ( 1 / scale ), 72 / ( 1 / scale )
		
		
		hullmin.x, hullmin.y = -16 / ( 1 / scale_overridexy ), -16 / ( 1 / scale_overridexy )
		hullmax.x, hullmax.y, hullmax.z = 16 / ( 1 / scale_overridexy ), 16 / ( 1 / scale_overridexy ), 72 / ( 1 / scale_overridez )
		v:SetHull( hullmin, hullmax )
		hullmax.z = hullmax.z / 2 
		v:SetHullDuck( hullmin, hullmax )
		v:SetViewOffset( Vector( 0, 0, 64 / ( 1 / scale ) ) )
		v:SetViewOffsetDucked( Vector( 0, 0, 28 / ( 1 / scale ) ) )
		v.AnusScaleModel = save
	end

	--if #exempt > 0 then anus.playerNotification( caller, "Couldn't scale ", exempt ) end
	--if #target == 0 then return end
	net.Start( "anus_plugins_Scale" )
		net.WriteFloat( scale )
	net.Send( target )
	anus.notifyPlugin( caller, plugin.id, "scaled ", target, " to ", anus.Colors.String, scale )
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	local menu, label = parent:AddSubMenu( self.name )
	
	local scale =
	{
		{ "Small", "0.25" },
		{ "Normal", "1" },
		{ "Big", "2" },
		{ "Huge", "4" },
	}
	
	for i=1,#scale do
		menu:AddOption( scale[ i ][ 1 ], function()
			pl:ConCommand( "anus " .. self.id .. " \"" .. target:Nick() .. "\" " .. scale[ i ][ 2 ] )
		end )
	end
	
	menu:AddOption( "Custom Scale", function()
		Derma_StringRequest( 
			target:Nick(), 
			"Custom Scale Multiplier",
			"1",
			function( txt )
				pl:ConCommand( "anus " .. self.id .. " \"" .. target:Nick() .. "\" " .. txt )
			end,
			function( txt ) 
			end
		)
	end )
	
end
anus.registerPlugin( plugin )

if SERVER then
	util.AddNetworkString( "anus_plugins_Scale" )
	
	anus.registerHook( "DoPlayerDeath", "scale", function( pl )
		if not pl.AnusScaleModel then
			pl:SetModelScale( 1 )
			pl:SetHull( Vector( -16, -16, 0 ), Vector( 16, 16, 72 ) )
			pl:SetCollisionBounds( Vector( -16, -16, 0 ), Vector( 16, 16, 72 ) )
			pl:SetHullDuck( Vector( -16, -16, 0 ), Vector( 16, 16, 36 ) )
			pl:SetViewOffset( Vector( 0, 0, 64 ) )
			pl:SetViewOffsetDucked( Vector( 0, 0, 28 ) )
			net.Start( "anus_plugins_Scale" )
				net.WriteFloat( 1 )
			net.Send( pl )
		end
	end, plugin.id )
else
	net.Receive( "anus_plugins_Scale", function()
		local scale = math.Round( net.ReadFloat(), 2 )
		local scale_overridexy = math.Clamp( scale, 0.8, 1.875 )
		local scale_overridez = math.Clamp( scale, 0.05, 1.125 )
	
		local hullmin, hullmax = LocalPlayer():GetHull()
		hullmin.x, hullmin.y = -16 / ( 1 / scale_overridexy ), -16 / ( 1 / scale_overridexy )
		hullmax.x, hullmax.y, hullmax.z = 16 / ( 1 / scale_overridexy ), 16 / ( 1 / scale_overridexy ), 72 / ( 1 / scale_overridez )
		LocalPlayer():SetHull( hullmin, hullmax )
		hullmax.z = hullmax.z / 2 
		LocalPlayer():SetHullDuck( hullmin, hullmax )
	end )
end

anus.registerHook( "UpdateAnimation", "scale", function( pl, vel, speed )
		-- idk any formulas sry
	local len = vel:Length() / (pl:GetModelScale()^(2-1.292484))      --pl:GetModelScale()--(2^(pl:GetModelScale()-1))
	local movement = 1.0

	if ( len > 0.2 ) then
		movement = ( len / speed )
	end

	local rate = math.min( movement, 2 )

	-- if we're under water we want to constantly be swimming..
	if ( pl:WaterLevel() >= 2 ) then
		rate = math.max( rate, 0.5 )
	elseif ( !pl:IsOnGround() && len >= 1000 ) then
		rate = 0.1
	end

	pl:SetPlaybackRate( rate )

	if ( pl:InVehicle() ) then

		local Vehicle = pl:GetVehicle()
		
		-- We only need to do this clientside..
		if ( CLIENT ) then
			--
			-- This is used for the 'rollercoaster' arms
			--
			local Velocity = Vehicle:GetVelocity()
			local fwd = Vehicle:GetUp()
			local dp = fwd:Dot( Vector( 0, 0, 1 ) )
			local dp2 = fwd:Dot( Velocity )

			pl:SetPoseParameter( "vertical_velocity", ( dp < 0 and dp or 0 ) + dp2 * 0.005 )

			-- Pass the vehicles steer param down to the player
			local steer = Vehicle:GetPoseParameter( "vehicle_steer" )
			steer = steer * 2 - 1 -- convert from 0..1 to -1..1
			if ( Vehicle:GetClass() == "prop_vehicle_prisoner_pod" ) then steer = 0 pl:SetPoseParameter( "aim_yaw", math.NormalizeAngle( pl:GetAimVector():Angle().y - Vehicle:GetAngles().y - 90 ) ) end
			pl:SetPoseParameter( "vehicle_steer", steer )

		end
		
	end

	if ( CLIENT ) then
		GAMEMODE:GrabEarAnimation( pl )
		GAMEMODE:MouthMoveAnimation( pl )
	end
	
	return true
end, plugin.id )