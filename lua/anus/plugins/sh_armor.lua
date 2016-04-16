local plugin = {}
plugin.id = "armor"
plugin.name = "Armor"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>; <number:armor>; [boolean:Subtract]"
plugin.args = {"Int;0;200","String;false"}
plugin.help = "Sets the armor of a player"
plugin.category = "Fun"
plugin.chatcommand = "armor"
plugin.defaultAccess = "admin"

	-- add support for subtracting a % of their current health
function plugin:OnRun( pl, args, target )
	local subtract = args[ 2 ] and tobool( args[ 2 ] ) or false
	local amt = math.Round( tonumber( args[ 1 ] ) )

	for k,v in next, target do
		if not pl:IsGreaterOrEqualTo( v ) then
			pl:ChatPrint( "Sorry, you can't target " .. v:Nick() )
			target[ k ] = nil
			continue
		end

		if not v:Alive() then
			target[ k ] = nil
			continue
		end

		v:SetArmor( (subtract and v:Armor() - amt or amt) )

	end

	if subtract then
		anus.NotifyPlugin( pl, plugin.id, "set the armor of ", anus.StartPlayerList, target, anus.EndPlayerList, " from their current to ", COLOR_STRINGARGS, amt )
	else
		anus.NotifyPlugin( pl, plugin.id, "set the armor of ", anus.StartPlayerList, target, anus.EndPlayerList, " to ", COLOR_STRINGARGS, amt )
	end
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	local menu, label = parent:AddSubMenu( self.name )
	
	local armor =
	{
	"100",
	"75",
	"50",
	"25",
	"1",
	}
	
	for i=1,#armor do
		menu:AddOption( armor[ i ], function()
			local runtype = target:SteamID()
			if target:IsBot() then runtype = target:Nick() end

			pl:ConCommand( "anus " .. self.chatcommand .. " " .. runtype .. " " .. armor[ i ] )
		end )
	end
	
	menu:AddOption( "Custom armor", function()
		Derma_StringRequest( 
			target:Nick(), 
			"Custom armor",
			"100",
			function( txt )
				local runtype = target:SteamID()
				if target:IsBot() then runtype = target:Nick() end

				pl:ConCommand( "anus " .. self.chatcommand .. " " .. runtype .. " " .. txt )
			end,
			function( txt ) 
			end
		)
	end )
	
end
anus.RegisterPlugin( plugin )