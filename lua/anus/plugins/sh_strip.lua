local plugin = {}
plugin.id = "strip"
plugin.name = "Strip Weapons"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>"
plugin.help = "Strips a player of their weapons"
plugin.category = "Fun"
	-- chat command optional
plugin.chatcommand = "strip"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, arg, target )
	if not target and IsValid( pl ) then
		target = pl
	end
		
	if type(target) == "table" then
	
		for k,v in pairs(target) do
			if not pl:IsGreaterOrEqualTo( v ) then
				pl:ChatPrint("Sorry, you can't target " .. v:Nick())
				target[ k ] = nil
				continue
			end
				
			v.OldWeapons = {}
			for _,b in pairs( v:GetWeapons() ) do
				v.OldWeapons[ #v.OldWeapons + 1 ] = b:GetClass()
			end

			v:StripWeapons()
		end

		anus.NotifyPlugin( pl, plugin.id, "stripped the weapons of ", anus.StartPlayerList, target, anus.EndPlayerList )
	
	else
		
		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint("Sorry, you can't target " .. target:Nick())
			return
		end
		
		target.OldWeapons = {}
		for k,v in pairs( target:GetWeapons() ) do
			target.OldWeapons[ #target.OldWeapons + 1 ] = v:GetClass()
		end

		anus.NotifyPlugin( pl, plugin.id, "stripped the weapons of ", target )
			 
		target:StripWeapons()
	
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
anus.RegisterHook( "PlayerDeath", "strip", function( pl )
	pl.OldWeapons = nil
end, plugin.id )