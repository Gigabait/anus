	-- todo: hook into playercanhearvoice
	-- but make sure it doesnt conflict with darkrp / nutscript to ensure players dont know
	-- also:
	-- hook into playersay?

	-- todo:
	-- draw tracer where player is pointing
local plugin = {}
plugin.id = "spectate"
plugin.chatcommand = { "!spectate" }
plugin.name = "Spectate"
plugin.author = "Shinycow"
--plugin.usage = "<player:Player>"
plugin.arguments = {
	{ Target = "player" },
}
plugin.description = "Spectates a player of your choice"
plugin.category = "Utility"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target )
	if not IsValid( caller ) then
		anus.notifyPlayer( caller, "You can't spectate as server console!" )
		return
	end

	target = target[ 1 ]
	if target == caller then
		anus.notifyPlayer( caller, "You can't spectate yourself" )
		return
	end
	
		-- player spectated someone else straight from another spectatee
	if caller.AnusSpectate and caller.AnusSpectate != target then
		plugin:SpectatePlayer( caller, caller.AnusSpectate ) 
	end

	plugin:SpectatePlayer( caller, target )

	local txt = caller.AnusSpectate != false and "started" or "stopped"
	local txt = txt .. " spectating "
	anus.notifyPlugin( caller, plugin.id, true, color_white, txt, target )
end

function plugin:OnUnload()
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

if SERVER then
	util.AddNetworkString( "anus_plugins_spectate" )
	function plugin:SpectatePlayer( pl, target )
		if pl.AnusSpectate and pl.AnusSpectate == target or not IsValid( target ) then
			if IsValid( target ) then
				target.AnusSpectating[ pl ] = nil
			end

			pl.AnusSpectate = false
			pl:enableSpawning()
		else
			target.AnusSpectating = target.AnusSpectating or {}
			target.AnusSpectating[ pl ] = true

			pl.AnusSpectate = target
			pl:disableSpawning()
		end
		net.Start( "anus_plugins_spectate" )
			net.WriteUInt( IsValid( target ) and target:EntIndex() or 255, 8 )
			net.WriteBool( pl.AnusSpectate == false )
		net.Send( pl )
	end

	anus.registerHook( "SetupPlayerVisibility", "spectate", function( pl )
		if pl.AnusSpectate and IsValid( pl.AnusSpectate ) then
			AddOriginToPVS( pl.AnusSpectate:GetPos() )
		end
	end, plugin.id )
	anus.registerHook( "KeyPress", "spectate", function( pl, key )
		if pl.AnusSpectate then
			if key == IN_FORWARD or key == IN_JUMP
			or key == IN_MOVELEFT or key == IN_MOVERIGHT then
				plugin:OnRun( pl, { pl.AnusSpectate } )
			end
		end
	end, plugin.id )
	anus.registerHook( "PlayerDisconnected", "spectate", function( pl )
		for spectator,_ in next, pl.AnusSpectating or {} do
			plugin:OnRun( spectator, { pl } )
		end
		if pl.AnusSpectate and IsValid( pl.AnusSpectate ) then
			plugin:OnRun( pl, { pl.AnusSpectate } )
		end
	end, plugin.id )
end

if CLIENT then
	net.Receive( "anus_plugins_spectate", function()
		local target = Entity( net.ReadUInt( 8 ) )
		local unspectate = net.ReadBool()

		LocalPlayer().AnusSpectate = unspectate != true and target != LocalPlayer() and target or false
		if LocalPlayer().AnusSpectate then
			if not LocalPlayer().AnusSpectateAng then
				LocalPlayer().AnusSpectateAng = LocalPlayer():EyeAngles()
				timer.Create( "anus_spectate_refresh", 2, 0, function()
					if not LocalPlayer().AnusSpectate or not IsValid( LocalPlayer().AnusSpectate ) then return end
					
					local Trace = LocalPlayer().AnusSpectate:GetEyeTrace()
					LocalPlayer().AnusSpectateLookingAt = nil
					if Trace.Entity != Entity( 0 ) and IsValid( Trace.Entity ) then
						LocalPlayer().AnusSpectateLookingAt = " (" .. Trace.Entity:EntIndex() .. ")"

						local Prepend = Trace.Entity:GetClass()
						if Trace.Entity.Nick then
							Prepend = Trace.Entity:Nick()
						end

						LocalPlayer().AnusSpectateLookingAt = Prepend .. LocalPlayer().AnusSpectateLookingAt

						if Trace.Entity.Health and Trace.Entity:Health() != 0 then
							LocalPlayer().AnusSpectateLookingAt = LocalPlayer().AnusSpectateLookingAt .. " - HP: " .. Trace.Entity:Health()
						end
					end
				end )
			end
		else
			if LocalPlayer().AnusSpectateAng then
				LocalPlayer():SetEyeAngles( LocalPlayer().AnusSpectateAng )
				LocalPlayer().AnusSpectateAng = nil
			end
		end
	end )

	anus.registerHook( "CalcView", "spectate", function( pl, pos, angles, fov )
		if LocalPlayer().AnusSpectate and IsValid( LocalPlayer().AnusSpectate ) then
			local view = {}
			view.angles = LocalPlayer().AnusSpectateXOffset and Angle( LocalPlayer().AnusSpectateYOffset or 0, LocalPlayer().AnusSpectateXOffset, 0 ) or angles
			view.origin = LocalPlayer().AnusSpectate:EyePos() - ( view.angles:Forward() * 50 )
			view.fov = fov
			view.drawviewer = true

			LocalPlayer().AnusSpectateViewData = view
			return view
		end
	end, plugin.id )

	local sensitivity = GetConVar( "sensitivity" )
	anus.registerHook( "InputMouseApply", "spectate", function( cmd, x, y, ang )
		local bonus = sensitivity:GetInt()
		local bonusx = x != 0 and ( bonus / (bonus / x) * 0.02 ) or 0
		local bonusy = y != 0 and ( bonus / (bonus / y) * 0.02 ) or 0
		
		LocalPlayer().AnusSpectateXOffset = math.NormalizeAngle( (LocalPlayer().AnusSpectateXOffset or ang.y) - bonusx )
		LocalPlayer().AnusSpectateYOffset = math.NormalizeAngle( (LocalPlayer().AnusSpectateYOffset or ang.p) + bonusy )
	end, plugin.id )

	anus.registerHook( "HUDPaint", "spectate", function()
		if LocalPlayer().AnusSpectate and IsValid( LocalPlayer().AnusSpectate ) then 
			surface.SetFont( "anus_SmallText" )
			local txt = "Spectating " .. LocalPlayer().AnusSpectate:Nick() .. " - HP: " .. LocalPlayer().AnusSpectate:Health()
			local txtsizew, txtsizeh = surface.GetTextSize( txt )
			local offset = 0
			
			if LocalPlayer().AnusSpectateLookingAt then
				local String = "Looking at: " .. LocalPlayer().AnusSpectateLookingAt
				local TxtSizeW2, TxtSizeH2 = surface.GetTextSize( String )
				draw.SimpleText( String, "anus_SmallText", ScrW() / 2 - TxtSizeW2 / 2, ScrH() / 2 - TxtSizeH2 - 90, color_white )
				
				offset = txtsizeh + TxtSizeH2 + 5
			end
			draw.SimpleText( txt, "anus_SmallText", ScrW() / 2 - txtsizew / 2, ScrH() / 2 - txtsizeh / 2 - ( 90 + offset ), color_white )
		end
	end, plugin.id )

	anus.registerHook( "CreateMove", "spectate", function( cmd )
		if LocalPlayer().AnusSpectate then
			cmd:SetViewAngles( LocalPlayer().AnusSpectateAng )
			return true
		end
	end, plugin.id )

	local eyetraceMaterial = Material( "effects/laser1" )
	anus.registerHook( "RenderScreenspaceEffects", "spectate", function()
		if LocalPlayer().AnusSpectate and IsValid( LocalPlayer().AnusSpectate ) then
			cam.Start3D( EyePos(), EyeAngles() )
				render.SetMaterial( eyetraceMaterial ) 
				render.DrawBeam( LocalPlayer().AnusSpectate:EyePos(), LocalPlayer().AnusSpectate:GetEyeTrace().HitPos, 20, 1, 100, Color( 255, 25, 25, 255 ) )
			cam.End3D()
		end
	end, plugin.id )
end