local plugin = {}
plugin.id = "noclip"
plugin.name = "Noclip"
plugin.author = "Shinycow"
plugin.usage = "[player:Player]"
plugin.help = "Toggle users' noclip"
plugin.category = "Utility"
	-- chat command optional
plugin.chatcommand = "noclip"
plugin.defaultAccess = "admin"

local nocliptbl =
{
[true] = MOVETYPE_NOCLIP,
[false] = MOVETYPE_WALK,
}
function plugin:OnRun( pl, args, target )
	for k,v in next, target do
		if not pl:IsGreaterOrEqualTo( v ) then
			pl:ChatPrint("Sorry, you can't target " .. v:Nick())
			continue
		end
			
		if not v:Alive() then continue end

		v.AnusNoclipped = not (v.AnusNoclipped or false)
		v:SetMoveType( nocliptbl[ v.AnusNoclipped ] )

		anus.NotifyPlugin( pl, plugin.id, (v.AnusNoclipped and "enabled" or "disabled") .. " noclip for ", team.GetColor( v:Team() ), v:Nick() )
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
anus.RegisterHook( "PlayerNoClip", "anus_plugins_noclip", function( pl )
	if pl:HasAccess( "noclip" ) then return true end
end, plugin.id )