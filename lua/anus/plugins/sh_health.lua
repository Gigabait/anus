-- Health and armor

local plugin = {}
plugin.id = "armor"
plugin.chatcommand = { "!armor" }
plugin.name = "Armor"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" },
	{ Armor = "number", 0 },
	{ Add = "boolean", false },
}
plugin.optionalarguments = {
	"Armor",
	"Add"
}
plugin.description = "Sets the armor of a player"
plugin.category = "Fun"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target, armor, armor_Add )
	local amt = math.Clamp( math.Round( armor ), 0, 2^31 - 1 )

	--local exempt = {}
	for k,v in ipairs( target ) do
		--[[if not caller:isGreaterOrEqualTo( v ) or not v:Alive() then
			exempt[ #exempt + 1 ] = v
			target[ k ] = nil
			continue
		end]]

		v:SetArmor( (armor_Add and v:Armor() + amt or amt) )
	end

	--if #exempt > 0 then anus.playerNotification( caller, "Couldn't change the armor of ", exempt ) end
	--if #target == 0 then return end

	if armor_Add then
		anus.notifyPlugin( caller, plugin.id, "added ", anus.Colors.String, amt, " armor to ", target )
	else
		anus.notifyPlugin( caller, plugin.id, "set the armor of ", target, " to ", anus.Colors.String, amt )
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
			pl:ConCommand( "anus " .. self.id .. " \"" .. target:Nick() .. "\" " .. armor[ i ] )
		end )
	end
	
	menu:AddOption( "Custom armor", function()
		Derma_StringRequest( 
			target:Nick(), 
			"Custom armor",
			"100",
			function( txt )
				pl:ConCommand( "anus " .. self.id .. " \"" .. target:Nick() .. "\" " .. txt )
			end,
			function( txt ) 
			end
		)
	end )
	
end
anus.registerPlugin( plugin )

local plugin = {}
plugin.id = "hp"
plugin.chatcommand = { "!hp", "!sethealth", "!health" }
plugin.name = "Health"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" },
	{ HP = "number", 100 },
	{ Add = "boolean", false },
}
plugin.optionalarguments = {
	"Add"
}
--plugin.usage = "<player:Player>; <number:hp>; [boolean:Subtract]"
--plugin.args = {"Int;0;200","String;false"}
plugin.description = "Sets the health of a player"
plugin.category = "Fun"
plugin.defaultAccess = "admin"

function plugin:OnRun( caller, target, hp, hp_Add )
	local amt = math.Clamp( math.Round( hp ), 0, 2^31 - 1 )

	--local exempt = {}
	for k,v in ipairs( target ) do
		--[[if not caller:isGreaterOrEqualTo( v ) or not v:Alive() then
			exempt[ #exempt + 1 ] = v
			target[ k ] = nil
			continue
		end]]

		v:SetHealth( (hp_Add and v:Health() + amt or amt) )
		if v:Health() <= 0 then
			v:Kill()
		end

	end

	--if #exempt > 0 then anus.notifyPlayer( caller, "Couldn't change the health of ", exempt ) end
--	if #target == 0 then return end

	if hp_Add then
		anus.notifyPlugin( caller, plugin.id, "added ", anus.Colors.String, amt, " hp to ", target )
	else
		anus.notifyPlugin( caller, plugin.id, "set the health of ", target, " to ", anus.Colors.String, amt )
	end
end

	-- pl: Player running command
	-- parent: The DMenu
	-- target: The player object of the line selected
	-- line: The DListViewLine itself
function plugin:SelectFromMenu( pl, parent, target, line )
	local menu, label = parent:AddSubMenu( self.name )
	
	local health =
	{
	"100",
	"75",
	"50",
	"25",
	"1",
	}
	
	for i=1,#health do
		menu:AddOption( health[ i ], function()
			pl:ConCommand( "anus " .. self.id .. " \"" .. target:Nick() .. "\" " .. health[ i ] )
		end )
	end
	
	menu:AddOption( "Custom health", function()
		Derma_StringRequest( 
			target:Nick(), 
			"Custom health",
			"100",
			function( txt )
				pl:ConCommand( "anus " .. self.id .. " \"" .. target:Nick() .. "\" " .. txt )
			end,
			function( txt ) 
			end
		)
	end )
	
end
anus.registerPlugin( plugin )