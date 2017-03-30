local plugin = {}
plugin.id = "goto"
plugin.chatcommand = { "!goto" }
plugin.name = "Goto"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player", 1 }
}
plugin.description = "Teleports to a player"
plugin.category = "Teleport"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target )
	if not IsValid( caller ) then
		caller:ChatPrint( "To goto a player would plain not work." )
		return
	end

	if #target > 1 then
		caller:ChatPrint( "You can't teleport to more than one person at once!" )
		return
	end
	
	target = target[ 1 ]
	
	if caller == target then
		caller:ChatPrint( "Inception is a no-no." )
		return
	end
	
	if not target:Alive() then
		caller:ChatPrint( target:Nick() .. " is dead!" )
		return
	end

	local pos = anus.teleportPlayer( caller, target, caller:GetMoveType() == MOVETYPE_NOCLIP )
	if not pos then
		local access = caller:hasAccess( "noclip" )
		local Message = access and "noclip has been enabled." or "turn on noclip."
		caller:ChatPrint( "There wasn't a spot to put you in; " .. Message )
		
		if access then
			if caller:InVehicle() then
				caller:ExitVehicle()
			end
			caller:SetMoveType( MOVETYPE_NOCLIP )
			caller.AnusNoclipped = true
			caller.AnusTeleportPos = caller:GetPos()
			caller:SetPos( target:GetPos() )
		else
			return
		end
	else
		if caller:InVehicle() then
			caller:ExitVehicle()
		end
		caller.AnusTeleportPos = caller:GetPos()
		caller:SetPos( pos )
		caller:SetLocalVelocity( Vector( 0, 0, 0 ) )
	end

	anus.notifyPlugin( caller, plugin.id, "teleported to ", target )
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	parent:AddOption( self.name, function()
		pl:ConCommand( "anus " .. self.id .. " \"" .. target:Nick() .. "\"" )
	end )
end
anus.registerPlugin( plugin )


local plugin = {}
plugin.id = "bring"
plugin.chatcommand = { "!bring" }
plugin.name = "Bring"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" },
	{ Force = "boolean" }
}
plugin.optionalarguments = 
{
	"Force"
}

plugin.description = "Teleports a player to yourself"
plugin.category = "Teleport"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target, force )
	if not IsValid( caller ) then
		caller:ChatPrint( "To bring a player would just plain not work." )
		return
	end
	
	local exempt = {}
	local teleported = {}
	for k,v in ipairs( target ) do
		if v == caller then	target[ k ] = nil continue end
		if not caller:isGreaterOrEqualTo( v ) or not v:Alive() then
			exempt[ #exempt + 1 ] = v
			target[ k ] = nil
			continue
		end

		local pos = anus.teleportPlayer( v, caller, force or v:GetMoveType() == "MOVETYPE_NOCLIP" )
		
		if pos then
			if v:InVehicle() then
				v:ExitVehicle()
			end
			v.AnusTeleportPos = v:GetPos()
			v:SetPos( pos )
			v:SetLocalVelocity( Vector( 0, 0, 0 ) )
			teleported[ #teleported + 1 ] = v
		else
				-- don't give up just yet!
			local pos2
			local noTele = false
			for a,b in next, teleported do
				pos2 = anus.teleportPlayer( v, b, ( force or v:GetMoveType() == "MOVETYPE_NOCLIP" ) )
				if pos2 then
					if v:InVehicle() then
						v:ExitVehicle()
					end
					v.AnusTeleportPos = v:GetPos()
					v:SetPos( pos2 )
					v:SetLocalVelocity( Vector( 0, 0, 0 ) )
					teleported[ #teleported + 1 ] = v
					break
				end
					
					-- ok give up.
				if #teleported == a then
					exempt[ #exempt + 1 ] = v
					target[ k ] = nil
					break
				end
			end
		end
	end

	if #exempt > 0 then
		anus.notifyPlayer( caller, "Couldn't bring ", target, " to you." )
	end
	if #target == 0 then return end
	anus.notifyPlugin( caller, plugin.id, "brought ", target, " to themself." )
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	parent:AddOption( self.name, function()
		pl:ConCommand( "anus " .. self.id .. " \"" .. target:Nick() .. "\"" )
	end )
end
anus.registerPlugin( plugin )


local plugin = {}
plugin.id = "return"
plugin.chatcommand = { "!return" }
plugin.name = "Return Player"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" }
}
plugin.description = "Returns teleported player to their previous pos"
plugin.category = "Teleport"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target )
	local exempt = {}
	for k,v in ipairs( target ) do
		if not caller:isGreaterOrEqualTo( v ) or not v:Alive() or not v.AnusTeleportPos then
			exempt[ #exempt + 1 ] = v
			target[ k ] = nil
			continue
		end
		
		local pos = anus.teleportPlayer( v, v.AnusTeleportPos, v:GetMoveType() == MOVETYPE_NOCLIP )
		if not pos then
			caller:ChatPrint( "Couldn't find a spot for " .. v:Nick() )
		else
			if v:InVehicle() then
				v:ExitVehicle()
			end
			v.AnusTeleportPos = nil
			v:SetPos( pos )
			v:SetLocalVelocity( Vector( 0, 0, 0 ) )
		end
		
	end

	if #exempt > 0 then anus.playerNotification( caller, "Couldn't return ", exempt ) end
	if #target == 0 then return end
	anus.notifyPlugin( caller, plugin.id, "returned ", target, " to their previous position." )
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