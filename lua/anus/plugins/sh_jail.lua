anus_jailedplayers = anus_jailedplayers or {}
function jailPlayer( pl, bJail )
	if bJail then
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
			cell:SetMoveType( MOVETYPE_NONE )
			cell:Spawn()
			if IsValid( cell:GetPhysicsObject() ) then
				cell:GetPhysicsObject():EnableMotion( false )
			end
			
			cell.IsJailCell = true
			pl.cells[ #pl.cells + 1 ] = cell
		end
		
		pl:SetPos( pl:GetPos() + Vector( 0, 0, 4 ) )
		pl.cellpos = pl:GetPos()
		pl.AnusJailed = true
		pl:DisableSpawning()
		
		anus_jailedplayers[ pl ] = cells
	else
		for k,v in next, pl.cells or {} do
			if not IsValid( v ) then continue end
			v:Remove()
		end
		
		pl.cellpos, pl.cells = nil, nil
		pl.AnusJailed = false
		pl:EnableSpawning()
		
		anus_jailedplayers[ pl ] = nil
	end
end

local plugin = {}
plugin.id = "jail"
plugin.name = "Jail"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>; [string:Reason]"
plugin.help = "Jails a player"
plugin.category = "Teleport"
	-- chat command optional
plugin.chatcommand = "jail"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, args, target )
	local force = args[ 1 ] and tobool( args[ 1 ] ) or false
	
	local jailed = target
	for k,v in next, target do
		if not pl:IsGreaterOrEqualTo( v ) then
			pl:ChatPrint( "Sorry, you can't target " .. v:Nick() )
			jailed[ k ] = nil
			continue
		end
			
		jailPlayer( v, true )
	end

	anus.NotifyPlugin( pl, plugin.id, "jailed ", anus.StartPlayerList, jailed, anus.EndPlayerList )
end

if SERVER then
	function plugin:OnUnload()
		for k,v in next, player.GetAll() do
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
		local runtype = target:SteamID()
		if target:IsBot() then runtype = target:Nick() end

		pl:ConCommand( "anus " .. self.chatcommand .. " " .. runtype )
	end )
end
anus.RegisterPlugin( plugin )

anus.RegisterHook( "PlayerSpawn", "jaill", function( pl )
	if pl.AnusJailed and pl.cellpos then
		pl:SetPos( pl.cellpos )
	end
end, plugin.id )
anus.RegisterHook( "Think", "jail", function()
	for v,_ in next, anus_jailedplayers do
		--print( v:GetPos():Distance( v.cellpos ) )
		if not IsValid( v ) then continue end
			
		if v.LastJailCheck and v.LastJailCheck <= CurTime() then
			if v:GetPos():DistToSqr( v.cellpos ) >= 95^2 then
				jailPlayer( v, true )
			end
			
			v.LastJailCheck = CurTime() + 0.25
		else
			if not v.LastJailCheck then
				if v:GetPos():DistToSqr( v.cellpos ) >= 95^2 then
					jailPlayer( v, true )
				end
			
				v.LastJailCheck = CurTime() + 0.25
			end
		end
	end
end, plugin.id )
anus.RegisterHook( "CanTool", "jail", function( pl, tr, tool )
	if IsValid( tr.Entity ) and tr.Entity.IsJailCell then return false end
	if pl.AnusJailed then return false end
end, plugin.id )
anus.RegisterHook( "CanProperty", "jail", function( pl, property, ent )
	if ent.IsJailCell then return false end
	if pl.AnusJailed then return false end
end, plugin.id )
anus.RegisterHook( "PhysgunPickup", "jail", function( pl, ent )
	if ent.IsJailCell then return false end
	if pl.AnusJailed then return false end
end, plugin.id )
anus.RegisterHook( "PlayerDisconnected", "jail", function( pl )
	if pl.AnusJailed then
		for k,v in next, pl.cells or {} do
			v:Remove()
		end
	end
end, plugin.id )




local plugin = {}
plugin.id = "unjail"
plugin.name = "Unjail"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>"
plugin.help = "Unjails a player"
plugin.category = "Teleport"
	-- chat command optional
plugin.chatcommand = "unjail"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, args, target )
	local force = args[ 1 ] and tobool( args[ 1 ] ) or false
	
	local jailed = target
	for k,v in next, target do
		if not pl:IsGreaterOrEqualTo( v ) then
			pl:ChatPrint( "Sorry, you can't target " .. v:Nick() )
			jailed[ k ] = nil
			continue
		end
			
		jailPlayer( v, false )
	end

	anus.NotifyPlugin( pl, plugin.id, "unjailed ", anus.StartPlayerList, jailed, anus.EndPlayerList )
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