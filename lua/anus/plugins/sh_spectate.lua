	-- todo: hook into playercanhearvoice
	-- but make sure it doesnt conflict with darkrp / nutscript to ensure players dont know
	-- also:
	-- hook into playersay?
local plugin = {}
plugin.id = "spectate"
plugin.name = "Spectate"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>"
plugin.help = "Spectates a player of your choice"
plugin.category = "Utility"
plugin.chatcommand = "spectate"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, arg, target )
	target = target[ 1 ]
	if target == pl then
		pl:ChatPrint( "You can't spectate yourself" )
		return
	end

	plugin:SpectatePlayer( pl, target )

	local txt = pl.AnusSpectate != false and "started" or "stopped"
	local txt = txt .. " spectating "
	anus.NotifyPlugin( pl, plugin.id, true, color_white, txt, target )
end

function plugin:OnUnload()
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

if SERVER then
	util.AddNetworkString( "anus_plugins_spectate" )
	function plugin:SpectatePlayer( pl, target )--, unspectate )
		--pl:Freeze( unspectate == nil )
		if pl.AnusSpectate and pl.AnusSpectate == target or not IsValid( target ) then
				-- todo: do a check to see if theres an object there
			--pl:SetPos( pl.OldSpectatePos )
			--pl.OldSpectatePos = nil
			pl.AnusSpectate = false
			pl:EnableSpawning()
		else
			if not pl.OldSpectatePos then
			--	pl.OldSpectatePos = pl:GetPos()
			end
			--pl:SetPos( Vector( 9999, 9999, 99999 ) )
			pl.AnusSpectate = target
			pl:DisableSpawning()
		end
		net.Start( "anus_plugins_spectate" )
			net.WriteUInt( target:EntIndex(), 8 )
			net.WriteBool( pl.AnusSpectate == false )
		net.Send( pl )
	end
	
	anus.RegisterHook( "SetupPlayerVisibility", "spectate", function( pl )
		if pl.AnusSpectate and IsValid( pl.AnusSpectate ) then
			AddOriginToPVS( pl.AnusSpectate:GetPos() )
		elseif pl.AnusSpectate and not IsValid( pl.AnusSpectate ) then
			plugin:OnRun( pl, {}, {pl.AnusSpectate} )
		end
	end, plugin.id )
	anus.RegisterHook( "KeyPress", "spectate", function( pl, key )
		if pl.AnusSpectate then
			if key == IN_FORWARD or key == IN_JUMP
			or key == IN_MOVELEFT or key == IN_MOVERIGHT then
				plugin:OnRun( pl, {}, {pl.AnusSpectate} )
			end
		end
	end, plugin.id )
	anus.RegisterHook( "FinishMove", "spectate", function( pl )
		if pl.AnusSpectate then
			--return true
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
			end
		else
			if LocalPlayer().AnusSpectateAng then
				LocalPlayer():SetEyeAngles( LocalPlayer().AnusSpectateAng )
				LocalPlayer().AnusSpectateAng = nil
			end
		end
	end )
	anus.RegisterHook( "CalcView", "spectate", function( pl, pos, angles, fov )
		if LocalPlayer().AnusSpectate and IsValid( LocalPlayer().AnusSpectate ) then
			--LocalPlayer():SetEyeAngles( LocalPlayer().AnusSpectateAng )
			--print( LocalPlayer().AnusSpectateXOffset )
		
			local view = {}
			view.angles = LocalPlayer().AnusSpectateXOffset and Angle( LocalPlayer().AnusSpectateYOffset or 0, LocalPlayer().AnusSpectateXOffset, 0 ) or angles
			view.origin = LocalPlayer().AnusSpectate:EyePos() - ( view.angles:Forward() * 50 )
			view.fov = fov
			view.drawviewer = true

			return view
		end
	end, plugin.id )
	local sensitivity = GetConVar( "sensitivity" )
	anus.RegisterHook( "InputMouseApply", "spectate", function( cmd, x, y, ang )
		local bonus = sensitivity:GetInt()
		local bonusx = x != 0 and ( bonus / (bonus / x) * 0.02 ) or 0--( bonus / ( 3 / x ) * 0.01 ) or 0
		local bonusy = y != 0 and ( bonus / (bonus / y) * 0.02 ) or 0--( bonus / ( 3 / y ) * 0.01 ) or 0
		LocalPlayer().AnusSpectateXOffset = math.NormalizeAngle( (LocalPlayer().AnusSpectateXOffset or ang.y) - bonusx )
		LocalPlayer().AnusSpectateYOffset = math.NormalizeAngle( (LocalPlayer().AnusSpectateYOffset or ang.p) + bonusy )
		--print( LocalPlayer().AnusSpectateYOffset )
	end, plugin.id )
	anus.RegisterHook( "HUDPaint", "spectate", function()
		if LocalPlayer().AnusSpectate and IsValid( LocalPlayer().AnusSpectate )then
			surface.SetFont( "anus_SmallText" )
			local txt = "Spectating " .. LocalPlayer().AnusSpectate:Nick()
			local txtsizew, txtsizeh = surface.GetTextSize( txt )
			
			draw.SimpleText( txt, "anus_SmallText", ScrW() / 2 - txtsizew / 2, ScrH() / 2 - txtsizeh / 2 - 80, color_white )
		end
	end, plugin.id )
	anus.RegisterHook( "CreateMove", "spectate", function( cmd )
		if LocalPlayer().AnusSpectate then
			--cmd:ClearButtons()
			--cmd:ClearMovement()
			cmd:SetViewAngles( LocalPlayer().AnusSpectateAng )
			return true
		end
	end, plugin.id )
		
end