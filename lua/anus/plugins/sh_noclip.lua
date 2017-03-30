local plugin = {}
plugin.id = "noclip"
plugin.chatcommand = { "!noclip" }
plugin.name = "Noclip"
plugin.author = "Shinycow"
plugin.arguments = {
	{ Target = "player" }
}
plugin.optionalarguments =
{
	"Target"
}
plugin.description = "Toggle users' noclip"
plugin.category = "Utility"
plugin.defaultAccess = "admin"

local nocliptbl =
{
[ true ]	= MOVETYPE_NOCLIP,
[ false ]	= MOVETYPE_WALK,
}
function plugin:OnRun( caller, target )
	target = target != nil and target or { caller }
	for k,v in next, target do
		--[[if not caller:isGreaterOrEqualTo( v ) then
			caller:ChatPrint( "Sorry, you can't target " .. v:Nick() )
			continue
		end]]
			
		if not v:Alive() then continue end

		local ShouldNoclip = false
		if v:GetMoveType() == MOVETYPE_WALK then
			ShouldNoclip = true
		else
			ShouldNoclip = false
		end
		v:SetMoveType( nocliptbl[ ShouldNoclip ] )

		anus.notifyPlugin( caller, plugin.id, (ShouldNoclip and "enabled" or "disabled") .. " noclip for ", team.GetColor( v:Team() ), v:Nick() )
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
if SERVER then
	anus.registerHook( "PlayerNoClip", "anus_plugins_noclip", function( pl, mode )
		if mode == false or pl:hasAccess( "noclip" ) then
			anus.serverLog( pl:Nick() .. " toggled noclip " .. tostring( mode ), true, true )
			return true 
		end
	end, plugin.id )
end