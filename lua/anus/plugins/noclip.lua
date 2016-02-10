local plugin = {}
plugin.id = "noclip"
plugin.name = "Noclip"
plugin.author = "Shinycow"
plugin.usage = "[player:Player]"
plugin.help = "Toggle users' noclip"
plugin.category = "Fun"
	-- chat command optional
plugin.chatcommand = "noclip"
plugin.defaultAccess = GROUP_ADMIN

local nocliptbl =
{
[true] = MOVETYPE_NOCLIP,
[false] = MOVETYPE_WALK,
}
function plugin:OnRun( pl, args, target )
	if not target and IsValid( pl ) then
		target = pl
	end

	if type(target) == "table" then
	
		for k,v in pairs(target) do
			if not pl:IsGreaterOrEqualTo( v ) then
				pl:ChatPrint("Sorry, you can't target " .. v:Nick())
				continue
			end
			
			if not v:Alive() then continue end

			v.AnusNoclipped = not (v.AnusNoclipped or false)
			--pl:ChatPrint( (v.AnusNoclipped and "Enabled" or "Disabled") .. " noclip for " .. v:Nick() )
			anus.NotifyPlugin( pl, plugin.id, color_white, (v.AnusNoclipped and "enabled" or "disabled") .. " noclip for ", team.GetColor( v:Team() ), v:Nick() )
			 
			v:SetMoveType( nocliptbl[ v.AnusNoclipped ] )
		end		
		
			-- new system
		---anus.NotifyPlugin( pl, plugin.id, color_white, "disabled godmode on ", anus.StartPlayerList, target, anus.EndPlayerList )
	
	
		-- actually never mind fUCK that lol
	
			-- pseudo new system:
		---anus.NotifyPlugin( pl, plugin.id, color_white, "%s noclip for ", anus.StartPlayerList( "AnusNoclipped",  ), target, anus.EndPlayerList )
		---
		---
		--[[
			function anus.StartPlayerList( shithere )
				if targettable[ shithere ] then
					
		----]]
	
	else
		
		if not pl:IsGreaterOrEqualTo( target ) then
			pl:ChatPrint("Sorry, you can't target " .. target:Nick())
			return
		end
		
		if not target:Alive() then
			pl:ChatPrint("You can't " .. ( (not (target.AnusNoclipped or false)) and "enable" or "disable" ) .. " noclip while " .. target:Nick() .. " is dead!")
			return
		end

		target.AnusNoclipped = not (target.AnusNoclipped or false)
		--pl:ChatPrint( (target.AnusNoclipped and "Enabled" or "Disabled") .. " noclip for " .. target:Nick() )
		anus.NotifyPlugin( pl, plugin.id, color_white, (target.AnusNoclipped and "enabled" or "disabled") .. " noclip for ", team.GetColor( target:Team() ), target:Nick() )			
			
		target:SetMoveType( nocliptbl[ target.AnusNoclipped ] )
	
	end
end
anus.RegisterPlugin( plugin )