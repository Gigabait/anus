anus_jailedplayers = anus_jailedplayers or {}
function jailPlayer( pl, bJail, time )
	if bJail then
		pl:SetMoveType( MOVETYPE_WALK )
		if pl.cells and pl.cellpos then
			pl:SetPos( pl.cellpos )
			return
		end
	 
		local cells =
		{
		{ model = "models/props_phx/construct/windows/window_curve360x2.mdl", pos = pl:GetPos(), ang = Angle( -0.044, 97.207, 0.088 ) },
		{ model = "models/props_phx/construct/windows/window_angle360.mdl", pos = pl:GetPos(), ang = Angle( -0.044, 97.207, 0.088 ) },
		{ model = "models/props_phx/construct/windows/window_angle360.mdl", pos = pl:GetPos() + Vector( 0, 0, 95.3 - 1 ), ang = Angle( -0.044, 97.207, 0.088 ) },
		}

		pl.cells = {}
		for k,v in next, cells do
			local cell = ents.Create( "prop_physics" )
			cell:SetModel( v.model )
			cell:SetPos( v.pos )
			cell:SetAngles( v.ang )
			cell:Spawn()
			cell:SetMoveType( MOVETYPE_NONE )
			if IsValid( cell:GetPhysicsObject() ) then
				cell:GetPhysicsObject():EnableMotion( false )
			end
			
			cell.IsJailCell = true
			cell.JailCellOwner = pl
			cell.JailCellPos = cell:GetPos()
			cell.JailCellAng = cell:GetAngles()
			pl.cells[ #pl.cells + 1 ] = cell
		end
		
		pl:SetPos( pl:GetPos() + Vector( 0, 0, 4 ) )
		pl.cellpos = pl:GetPos()
		pl.AnusJailed = true
		pl:disableSpawning()

		anus_jailedplayers[ pl ] = cells
		timer.Simple( 0.1, function()
			if not IsValid( pl ) or not pl.cells then return end

			net.Start( "anus_plugins_Jail" )
				net.WriteEntity( pl )
				net.WriteBit( 1 )
				for i=1,3 do
					net.WriteUInt( pl.cells[ i ]:EntIndex(), 12 )
				end
			net.Broadcast()
		end )
		
		timer.createPlayer( pl, "anus_FixJailCellPos", 1, 0, function()
			if not pl.AnusJailed then timer.destroyPlayer( pl, "anus_FixJailCellPos" ) return end
			
			for k,v in ipairs( pl.cells ) do
				if not IsValid( v ) then continue end

				if v.JailCellPos != v:GetPos() or v.JailCellAng != v:GetAngles() then
					v:SetPos( v.JailCellPos )
					v:SetAngles( v.JailCellAng )
				end
			end
		end )
		if not time and timer.Exists( "anus_AutoUnjail" .. pl:UserID() ) then
			timer.Remove( "anus_AutoUnjail" .. pl:UserID() )
		elseif time and time != 0 then
			timer.createPlayer( pl, "anus_AutoUnjail" .. pl:UserID(), time, 1, function()
				jailPlayer( pl, false )
			end )
		end
	else
		for k,v in next, pl.cells or {} do
			if not IsValid( v ) then continue end
			v:Remove()
		end
		
		pl.cellpos, pl.cells = nil, nil
		pl.AnusJailed = false
		pl:enableSpawning()
		
		anus_jailedplayers[ pl ] = nil
		timer.Simple( 0.11, function()
			net.Start( "anus_plugins_Jail" )
				net.WriteEntity( pl )
				net.WriteBit( 0 )
			net.Broadcast()
		end )
	end
end

local plugin = {}
plugin.id = "jail"
plugin.chatcommand = { "!jail" }
plugin.name = "Jail"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" },
	{ Time = "number" },
	{ Reason = "string" },
}
plugin.optionalarguments =
{
	"Time",
	"Reason"
}
plugin.description = "Entraps a player, strips them of their basic player rights"
plugin.category = "Fun"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target, time )
	time = time and math.Clamp( time, 0, 60*60 ) or 0
	--local exempt = {}
	for k,v in ipairs( target ) do
		--[[if not caller:isGreaterOrEqualTo( v ) then
			exempt[ #exempt + 1 ] =v
			target[ k ] = nil
			continue
		end]]
			
		jailPlayer( v, true, time )
	end

	--if #exempt > 0 then anus.playerNotification( caller, "Couldn't jail ", exempt ) end
	--if #target == 0 then return end
	if time != 0 then
		anus.notifyPlugin( caller, plugin.id, "jailed ", target, " for ", anus.Colors.String, time, " seconds" )
	else
		anus.notifyPlugin( caller, plugin.id, "jailed ", target )
	end
end

if SERVER then
	util.AddNetworkString( "anus_plugins_Jail" )
	
	function plugin:OnUnload()
		for k,v in ipairs( player.GetAll() ) do
			jailPlayer( v, false )
		end
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

anus.registerHook( "PlayerSpawn", "jaill", function( pl )
	if pl.AnusJailed and pl.cellpos then
		pl:SetPos( pl.cellpos )
	end
end, plugin.id )
anus.registerHook( "Think", "jail", function()
	for v,_ in next, anus_jailedplayers do
		if not IsValid( v ) then 
			anus_jailedplayers[ v ] = nil
			continue
		end
			
		if not v.LastJailCheck or (v.LastJailCheck and v.LastJailCheck <= CurTime()) then
			if v:GetPos():DistToSqr( v.cellpos ) >= 92^2 then
				jailPlayer( v, true )
			end
			
			v.LastJailCheck = CurTime() + 0.25
		end
	end
end, plugin.id )
anus.registerHook( "CanTool", "jail", function( pl, tr, tool )
	if IsValid( tr.Entity ) and tr.Entity.IsJailCell then return false end
	if pl.AnusJailed then return false end
end, plugin.id )
anus.registerHook( "CanProperty", "jail", function( pl, property, ent )
	if ent.IsJailCell then return false end
	if pl.AnusJailed then return false end
end, plugin.id )
anus.registerHook( "PhysgunPickup", "jail", function( pl, ent )
	if ent.IsJailCell then return false end
	if pl.AnusJailed then return false end
end, plugin.id )
if SERVER then
	anus.registerHook( "PlayerDisconnected", "jail", function( pl )
		if pl.AnusJailed then
			for k,v in next, pl.cells or {} do
				if IsValid( v ) then
					v:Remove()
				end
			end
		end
	end, plugin.id )
else
	net.Receive( "anus_plugins_Jail", function()
		local ent = net.ReadEntity()
		local enabled = net.ReadBit()

		jailCells = jailCells or {}
		ent.JailCells = {}

		if not enabled then
			jailCells[ ent ] = nil
			return
		end

		for i=1,3 do
			local cell = net.ReadUInt( 12 )
			ent.JailCells[ i ] = Entity( cell )
			
			if i == 1 then
				jailCells[ ent ] = Entity( cell )
			end
		end
	end )
	
	anus.registerHook( "PostDrawTranslucentRenderables", "jail", function()
		for pl,cell in next, jailCells or {} do
			if not IsValid( cell ) then continue end
			if cell:GetPos():DistToSqr( LocalPlayer():GetPos() ) > 600^2 then continue end
			
				-- eugh
			local ang = cell:GetAngles()
			for i=1,2 do
				local add = i == 1 and Vector( 52, 0, 64 ) or Vector( -52, 0, 64 )
				local pos = cell:GetPos() + add + ang:Up()
				if i == 1 then
					ang:RotateAroundAxis( ang:Forward(), 90 )
					ang:RotateAroundAxis( ang:Right(), 0 )
				else
					ang:RotateAroundAxis( ang:Forward(), 0 )
					ang:RotateAroundAxis( ang:Right(), 180 )
				end

				cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.4 ) 
						draw.DrawText( string.Pluralize( pl:Nick() ) .. " jail cell", "anus_SmallText",  8, 2, Color( 250, 25, 20, 255 ), TEXT_ALIGN_CENTER )
				cam.End3D2D()
			end
		end
	end, plugin.id )
end




local plugin = {}
plugin.id = "unjail"
plugin.chatcommand = { "!unjail" }
plugin.name = "Unjail"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" }
}
plugin.description = "Unjails a player"
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
			
		jailPlayer( v, false )
	end

	--if #exempt > 0 then anus.playerNotification( caller, "Couldn't unjail ", exempt ) end
	--if #target == 0 then return end
	anus.notifyPlugin( caller, plugin.id, "unjailed ", target )
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