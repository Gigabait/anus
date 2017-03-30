local plugin = {}
plugin.id = "scoreboard"
plugin.name = "Scoreboard"
plugin.author = "Shinycow"
plugin.description = "Adds administrative use to base scoreboard"
plugin.notRunnable = true
plugin.category = "Misc"
plugin.defaultAccess = "owner"

function plugin:OnRun( caller, target )
end

anus.registerPlugin( plugin )

if CLIENT then
	local OptionsShow =
	{
		{
			"spectate", "Spectate", "icon16/eye.png"
		},
		{
			"goto", "Goto", "icon16/door_in.png"
		},
		{
			"bring", "Bring", "icon16/door_out.png"
		},
		{
			"slay", "Slay", "icon16/heart_delete.png"
		},
		{
			"jail", "Jail", "icon16/anchor.png"
		},
		{
			"unjail", "Unjail", "icon16/link_break.png"
		},
		{
			"kick", "Kick", "icon16/user_delete.png"
		}
	}
	anus.registerHook( "ScoreboardShow", "anus_plugins_Scoreboard", function()
			-- We have a delay so that new entries will show the button.
		timer.Create( "ScoreboardShow", 0.2, 1, function()
			if not IsValid( g_Scoreboard ) or not g_Scoreboard.Scores then return end

			local pnl = g_Scoreboard
			for k,v in ipairs( pnl.Scores:GetCanvas():GetChildren() ) do
				v.NiceButton = v:Add( "DButton" )
				v.NiceButton:SetText( "" )
				v.NiceButton:SetPos( 33, 0 ) 
					-- size - (avatar + mute)
				v.NiceButton:SetSize( v:GetSize() - (33 + 33), 32 + 3 * 2 )
				v.NiceButton.Paint = function() end
				v.NiceButton.DoClick = function()
					local Menu = DermaMenu()
					Menu:AddOption( v.Player:GetUserGroup():upper() ) 

						-- :v
					for i=1, 10 do
						Menu:AddSpacer()
					end
		
					for x,y in ipairs( OptionsShow ) do
						if not LocalPlayer():hasAccess( y[ 1 ] ) then continue end
						
						Menu:AddOption( y[ 2 ], function()
							LocalPlayer():ConCommand( "anus " .. y[ 1 ] .. " \"" .. v.Name:GetText() .. "\"" )
						end ):SetIcon( y[ 3 ] )
					end

					Menu:Open()
					Menu.Think = function( pnl )
						if not v.NiceButton or not IsValid( v.NiceButton ) then
							pnl:Remove()
						end
					end
				end
			end
		end )
	end, plugin.id )
		-- wont be needed when we are done, just doa check in scoreboardshow
		-- check if v.NiceButton already exists
	anus.registerHook( "ScoreboardHide", "anus_plugins_Scoreboard", function()
		if not IsValid( g_Scoreboard ) or not g_Scoreboard.Scores then return end
		
		local pnl = g_Scoreboard
		for k,v in ipairs( pnl.Scores:GetCanvas():GetChildren() ) do
			if v.NiceButton and IsValid( v.NiceButton ) then
				v.NiceButton:Remove()
			end
		end
	end, plugin.id )
end