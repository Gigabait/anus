--------------------------------------------------------
--------------------------------------------------------
----------------
---------------- I'm so sorry who ever is reading this code, I literately cannot make menus for shit.
----------------
--------------------------------------------------------
--------------------------------------------------------

-- new https://kuler.adobe.com/inspiration-color-theme-3985225/
-- https://kuler.adobe.com/inspiration-color-theme-3985225/edit/?copy=true


local panel = {}

surface.CreateFont( "anus_SmallTitle",
{
	--font = "Arial",
	font = "Verdana",
	size = 21,
} )
surface.CreateFont( "anus_SmallTitleFancy",
{
	font = "Wide Latin",
	size = 20,
} )
surface.CreateFont( "anus_MediumTitle",
{
	font = "Verdana",
	size = 23,
} )
surface.CreateFont( "anus_MediumTitleFancy",
{
	font = "Dayton", --"Wide Latin",
	size = 22,
} )
surface.CreateFont( "anus_BigTitle",
{
	--font = "Arial",
	font = "Verdana",
	size = 26,
} )
surface.CreateFont( "anus_BigTitleFancy",
{
	font = "Dayton", --"Wide Latin",
	size = 25,
} )

local psizew,psizeh = 250, 400
local oldpsizeh = psizeh
local boxsizew,boxsizeh = 5, 5
local bgColor = Color( 10, 28, 40, 255 )
function panel:Init()
	self:SetSize( psizew, psizeh )
	self:SetPos( 100, 40 )
		-- basically MakePopup() except we can toggle the menu / walk around now.
	self:SetKeyBoardInputEnabled( true )
	gui.EnableScreenClicker( true )

	self.Fake = self:Add("DPanel")
	self.Fake:SetWide( sizew )
	self.Fake:Dock( TOP )
	self.Fake.Paint = function() end
	
	self.AdminInfo = self:Add("DPanel")
	self.AdminInfo:SetWide( sizew )
	self.AdminInfo:Dock( TOP )
	self.AdminInfo.Paint = function( pnl, w, h ) end
	
	self.AdminInfo.Rank = self.AdminInfo:Add( "DLabel" )
	self.AdminInfo.Rank:SetText( "Rank: " .. string.NiceName(LocalPlayer():GetUserGroup()) )
	self.AdminInfo.Rank:Dock( FILL )
	self.AdminInfo.Rank:AlignLeft( 20 )
	if LocalPlayer().PlayerInfo and LocalPlayer().PlayerInfo[ LocalPlayer() ]["time"] > 0 then
		self.AdminInfo.Rank:SetFont( "anus_MediumTitleFancy" )
	else
		self.AdminInfo.Rank:SetFont( "anus_SmallTitleFancy" )
	end
	self.AdminInfo.Rank:SetContentAlignment( 2 )
	self.AdminInfo.Rank:SetTextColor( Color( 0, 36, 60, 255 ) )
	self.AdminInfo.Rank:SizeToContents()

	if LocalPlayer().PlayerInfo and LocalPlayer().PlayerInfo[ LocalPlayer() ]["time"] > 0 then
		self.AdminTime = self:Add("DPanel")
		self.AdminTime:SetWide( sizew )
		self.AdminTime:Dock( TOP )
		self.AdminTime.Paint = function() end
		
		self.AdminTime.Time = self.AdminTime:Add( "DLabel" )
		self.AdminTime.Time:SetText( "Time Left: " .. LocalPlayer().PlayerInfo[ LocalPlayer() ]["time"] .. " minutes")
		self.AdminTime.Time:AlignLeft( 20 )
		self.AdminTime.Time:Dock( FILL )
		self.AdminTime.Time:SetFont( "anus_MediumTitle" )
		self.AdminTime.Time:SetContentAlignment( 2 )
		self.AdminTime.Time:SetTextColor( Color( 0, 36, 60, 255 ) )
		self.AdminTime.Time:SizeToContents()
		
		psizeh = oldpsizeh + 20
	else
		psizeh = oldpsizeh
	end
	
	self.AdminDiv = self:Add("DPanel")
	self.AdminDiv:SetWide( sizew )
	self.AdminDiv:Dock( TOP )
	self.AdminDiv.Paint = function( pnl, w, h )
		surface.SetDrawColor( bgColor )
		--self.AdminDiv:SetSkin( "ANUS_ACTUAL" )
			-- psizeh * 0.01
		surface.DrawRect( boxsizew, psizeh * 0.031, psizew - 10, psizeh)
	end
	
	surface.SetFont("anus_BigTitle")
		
	local hovered = nil
	
	local pluginsname = "PLUGINS"
	local pluginsicon = "icon16/plugin.png"
	local pluginw,pluginh = surface.GetTextSize( pluginsname )
	local bansname = "BANS"
	local bansicon = "icon16/application_view_list.png"
	local bansw,bansh = surface.GetTextSize( bansname )
	local groupsname = "GROUPS"
	local groupsicon = "icon16/group_edit.png"
	local groupw,grouph = surface.GetTextSize( groupsname )
	local kickname = "QUICK KICK"
	local kickicon = "icon16/transmit.png"
	local kickw,kickh = surface.GetTextSize( kickname )
	local banname = "QUICK BAN"
	local banicon = "icon16/transmit_blue.png"
	local banw,banh = surface.GetTextSize( banname )
	if LocalPlayer().PlayerInfo and table.Count(LocalPlayer().PlayerInfo[ LocalPlayer() ]["perms"]) != 0 then
		self.PluginsFake = self:Add("DPanel")
		self.PluginsFake:SetWide( sizew )
		self.PluginsFake:SetTall( self.PluginsFake:GetTall() * 0.55 )
		self.PluginsFake:Dock( TOP )
		self.PluginsFake.Paint = function() end
		
		self.Plugins = self:Add("DPanel")
		self.Plugins:SetWide( sizew )
		self.Plugins:SetTall( self.Plugins:GetTall() - 1 )
		self.Plugins:Dock( TOP )
		self.Plugins.Paint = function() end
		
		self.Plugins.Button = self.Plugins:Add( "DButton" )
		self.Plugins.Button:SetFont( "anus_BigTitle" )
		self.Plugins.Button:SetText( pluginsname )
		self.Plugins.Button:SetTextColor( Color( 88, 122, 153, 255 ) )
		self.Plugins.Button:AlignTop( pluginh * 0.19 )
		self.Plugins.Button:AlignLeft( -10 )
		self.Plugins.Button:Dock( FILL )
		self.Plugins.Button:SetSize( psizew * 0.5, pluginh )
		self.Plugins.Button.DoClick = function()
			if anus_PluginsMenu and IsValid(anus_PluginsMenu) then
				anus_PluginsMenu:Remove()
				anus_PluginsMenu = nil
			else
				anus_PluginsMenu = vgui.Create("anus_pluginsmenu")
			end
		end
		self.Plugins.Button.Think = function( pnl )
			if pnl.Hovered then hovered = pnl end
		end
		local pluginspanelw,pluginspanelh = self.Plugins:GetPos()
		self.Plugins.Button.Paint = function( pnl, w, h )
			if pnl.Hovered then
				--pnl:SetTextColor( Color( 191, 153, 96, 255 ) )
				pnl:SetTextColor( Color( 151, 191, 183, 255 ) )
			else
				--pnl:SetTextColor( Color( 128, 112, 89, 255 ) )
				pnl:SetTextColor( Color( 67, 132, 142, 255  ) )
			end
		end
		
		self.Plugins.Button.Image = self.Plugins.Button:Add( "DImage" )
		self.Plugins.Button.Image:SetImage( pluginsicon )
		self.Plugins.Button.Image:SetSize( 20, 20 )
		local pluginsbuttonw, pluginsbuttonh = self.Plugins.Button:GetPos()
		local pluginiconsize = surface.GetTextureSize( surface.GetTextureID( pluginsicon ) )
		self.Plugins.Button.Image:SetPos( 20, pluginsbuttonh - 1 )
		
		self.PluginsDiv = self:Add("DPanel")
		self.PluginsDiv:SetWide( sizew )
		self.PluginsDiv:Dock( TOP )
		self.PluginsDiv.Paint = function( pnl, w, h )
			surface.SetDrawColor( bgColor )
			surface.DrawRect( boxsizew, psizeh * 0.031, psizew - 10, psizeh)
		end
		--self.PluginsDiv:SetSkin( "ANUS_ACTUAL" )
	end
	
	if LocalPlayer().PlayerInfo and LocalPlayer().PlayerInfo[ LocalPlayer() ]["perms"]["ban"] then
		self.BansFake = self:Add("DPanel")
		self.BansFake:SetWide( sizew )
		self.BansFake:SetTall( self.BansFake:GetTall() * 0.55 )
		self.BansFake:Dock( TOP )
		self.BansFake.Paint = function() end
	
		self.Bans = self:Add("DPanel")
		self.Bans:SetWide( sizew )
		self.Bans:SetTall( self.Bans:GetTall() - 1 )
		self.Bans:Dock( TOP )
		self.Bans.Paint = function() end
		
		self.Bans.Button = self.Bans:Add( "DButton" )
		self.Bans.Button:SetFont( "anus_BigTitle" )
		self.Bans.Button:SetText( bansname )
		self.Bans.Button:SetTextColor( Color( 0, 120, 190, 255 ) )
		self.Bans.Button:AlignTop( banh * 0.37 )
		self.Bans.Button:AlignLeft( -10 )
		self.Bans.Button:Dock( FILL )
		self.Bans.Button:SetSize( (psizew * 0.5) - (pluginw - bansw), bansh )
		self.Bans.Button.DoClick = function()
			if anus_BansMenu and IsValid(anus_BansMenu) then
				anus_BansMenu:Remove()
				anus_BansMenu = nil
			else
				anus_BansMenu = vgui.Create("anus_bansmenu")
			end
		end
		self.Bans.Button.Think = function( pnl )
			if pnl.Hovered then hovered = pnl end
		end
		self.Bans.Button.Paint = function( pnl )
			if pnl.Hovered then
				--pnl:SetTextColor( Color( 191, 153, 96, 255 ) )
				pnl:SetTextColor( Color( 151, 191, 183, 255 ) )
			else
				--pnl:SetTextColor( Color( 128, 112, 89, 255 ) )
				pnl:SetTextColor( Color( 67, 132, 142, 255 ) )
			end
		end
		
		self.Bans.Button.Image = self.Bans.Button:Add( "DImage" )
		self.Bans.Button.Image:SetImage( bansicon )
		self.Bans.Button.Image:SetSize( 20, 20 )
		local bansbuttonw, bansbuttonh = self.Bans.Button:GetPos()
		local baniconsize = surface.GetTextureSize( surface.GetTextureID( bansicon ) )
		self.Bans.Button.Image:SetPos( 20, bansbuttonh - 5 )
		
		self.BansDiv = self:Add("DPanel")
		self.BansDiv:SetWide( sizew )
		self.BansDiv:Dock( TOP )
		self.BansDiv.Paint = function( pnl, w, h )
			surface.SetDrawColor( bgColor )
			surface.DrawRect( boxsizew, psizeh * 0.031, psizew - 10, psizeh)
		end
	end
	
	if LocalPlayer().PlayerInfo and LocalPlayer().PlayerInfo[ LocalPlayer() ]["perms"]["configuregroups"] then
		self.GroupsFake = self:Add("DPanel")
		self.GroupsFake:SetWide( sizew )
		self.GroupsFake:SetTall( self.GroupsFake:GetTall() * 0.55 )
		self.GroupsFake:Dock( TOP )
		self.GroupsFake.Paint = function() end
	
		self.Groups = self:Add("DPanel")
		self.Groups:SetWide( sizew )
		self.Groups:SetTall( self.Groups:GetTall() - 1 )
		self.Groups:Dock( TOP )
		self.Groups.Paint = function() end
		
		self.Groups.Button = self.Groups:Add( "DButton" )
		self.Groups.Button:SetFont( "anus_BigTitle" )
		self.Groups.Button:SetText( groupsname )
		self.Groups.Button:SetTextColor( Color( 0, 120, 190, 255 ) )
		self.Groups.Button:AlignTop( grouph * 0.288 )
		self.Groups.Button:AlignLeft( -10 )
		self.Groups.Button:Dock( FILL )
		self.Groups.Button:SetSize( (psizew * 0.5) - (pluginw - groupw), grouph )
		self.Groups.Button.DoClick = function()
			if anus_GroupsMenu and IsValid(anus_GroupsMenu) then
				anus_GroupsMenu:Remove()
				anus_GroupsMenu = nil
			else
				anus_GroupsMenu = vgui.Create("anus_groupsmenu")
			end
		end
		self.Groups.Button.Think = function( pnl )
			if pnl.Hovered then hovered = pnl end
		end
		self.Groups.Button.Paint = function( pnl )
			if pnl.Hovered then
				--pnl:SetTextColor( Color( 191, 153, 96, 255 ) )
				pnl:SetTextColor( Color( 151, 191, 183, 255 ) )
			else
				--pnl:SetTextColor( Color( 128, 112, 89, 255 ) )
				pnl:SetTextColor( Color( 67, 132, 142, 255 ) )
			end
		end
		
		self.Groups.Button.Image = self.Groups.Button:Add( "DImage" )
		self.Groups.Button.Image:SetImage( groupsicon )
		self.Groups.Button.Image:SetSize( 20, 20 )
		local groupsbuttonw, groupsbuttonh = self.Groups.Button:GetPos()
		local groupsiconsize = surface.GetTextureSize( surface.GetTextureID( groupsicon ) )
		self.Groups.Button.Image:SetPos( 20, groupsbuttonh - 5 )
		
		self.GroupsDiv = self:Add("DPanel")
		self.GroupsDiv:SetWide( sizew )
		self.GroupsDiv:Dock( TOP )
		self.GroupsDiv.Paint = function( pnl, w, h )
			surface.SetDrawColor( bgColor )
			surface.DrawRect( boxsizew, psizeh * 0.031, psizew - 10, psizeh)
		end
	end
	
	if LocalPlayer().PlayerInfo and LocalPlayer().PlayerInfo[ LocalPlayer() ]["perms"]["kick"] then
		self.QKickFake = self:Add("DPanel")
		self.QKickFake:SetWide( sizew )
		self.QKickFake:SetTall( self.QKickFake:GetTall() * 0.55 )
		self.QKickFake:Dock( TOP )
		self.QKickFake.Paint = function() end
	
		self.QKick = self:Add("DPanel")
		self.QKick:SetWide( sizew )
		self.QKick:SetTall( self.QKick:GetTall() - 1 )
		self.QKick:Dock( TOP )
		self.QKick.Paint = function() end
		
		self.QKick.Button = self.QKick:Add( "DButton" )
		self.QKick.Button:SetFont( "anus_BigTitle" )
		self.QKick.Button:SetText( kickname )
		self.QKick.Button:SetTextColor( Color( 0, 120, 190, 255 ) )
		self.QKick.Button:AlignTop( kickh * 0.37 )
		self.QKick.Button:AlignLeft( -10 )
		self.QKick.Button:Dock( FILL )
		self.QKick.Button:SetSize( (psizew * 0.5) - (groupw - kickw), kickh )
		self.QKick.Button.DoClick = function()
		end
		anus_qkick_menu = anus_qkick_menu or nil
		local qkick_menuw,qkick_menuh = nil
		local qkick_mousew,qkick_mouseh = gui.MousePos()
		self.QKick.Button.Think = function( pnl )
			if pnl.Hovered then hovered = pnl end
			
			if hovered != pnl then
				if IsValid(anus_qkick_menu) then
					anus_qkick_menu:Remove()
					anus_qkick_menu = nil
				end
			else
				if not IsValid(anus_qkick_menu) then
					anus_qkick_menu = vgui.Create("DMenu")
					local qkickw,qkickh = self.QKick:GetPos()
					anus_qkick_menu:SetPos( psizew + (anus_qkick_menu:GetWide() * 1.5), qkickh + 26 )
					qkick_menuw,qkick_menuh = anus_qkick_menu:GetPos()
					
					anus_qkick_menu:AddOption("Close", function()
						anus_qkick_menu:Remove()
						anus_qkick_menu = nil
						
						hovered = nil
						
						local pposw,pposh = self:GetPos()
						gui.SetMousePos( pposw, pposh )
					end):SetIcon( "icon16/cancel.png" )
					anus_qkick_menu:AddSpacer()
					
					for i=1,#player.GetAll() do
						if not IsValid(player.GetAll()[ i ]) then continue end
						local ply = anus_qkick_menu:AddSubMenu( player.GetAll()[ i ]:Nick(), function( this )
							if not IsValid( player.GetAll()[ i ] ) then return end
							if player.GetAll()[ i ]:IsBot() then
								RunConsoleCommand( "anus_kick", player.GetAll()[ i ]:Nick() )
							else
								RunConsoleCommand( "anus_kick", player.GetAll()[ i ]:SteamID() )
							end
							
							if IsValid(anus_qkick_menu) then
								anus_qkick_menu:Remove()
								anus_qkick_menu = nil
								
								hovered = nil
								timer.Create("anus_reopenkick", math.Clamp(0.13 * (#player.GetAll() * 0.05 ), 0.13, 0.19), 1, function()
									if not IsValid(self) then return end
									hovered = pnl
								end)
							end
						end )
						
						local menu_tbl = {
							"General disruption.",
							"Mic spam.",
							"DISRESPECTFUL",
						}
						
						for z=1,#menu_tbl do
							ply:AddOption( menu_tbl[ z ], function()
								if not IsValid( player.GetAll()[ i ] ) then return end
								if player.GetAll()[ i ]:IsBot() then
									RunConsoleCommand( "anus_kick", player.GetAll()[ i ]:Nick(), menu_tbl[ z ] )
								else
									RunConsoleCommand( "anus_kick", player.GetAll()[ i ]:SteamID(), menu_tbl[ z ] )
								end
								
								if IsValid(anus_qkick_menu) then
									anus_qkick_menu:Remove()
									anus_qkick_menu = nil
									
									hovered = nil
									timer.Create("anus_reopenkick", 0.11 * (#player.GetAll() * 0.04), 1, function()
										if not IsValid(self) then return end
										hovered = pnl
									end)
								end
							end ):SetIcon( LocalPlayer().PlayerInfo and LocalPlayer().PlayerInfo[ player.GetAll()[ i ] ] and anus.Groups[ LocalPlayer().PlayerInfo[ player.GetAll()[ i ] ]["group"] ].icon or "icon16/bullet_error.png" )
						end
					end
				end
			end
			self.QKick.Button.Paint = function( pnl )
				if pnl.Hovered then
					--pnl:SetTextColor( Color( 191, 153, 96, 255 ) )
					pnl:SetTextColor( Color( 151, 191, 183, 255 ) )
				else
					--pnl:SetTextColor( Color( 128, 112, 89, 255 ) )
					pnl:SetTextColor( Color( 67, 132, 142, 255 ) )
				end
			end
		end
		
		self.QKick.Button.Image = self.QKick.Button:Add( "DImage" )
		self.QKick.Button.Image:SetImage( kickicon )
		self.QKick.Button.Image:SetSize( 20, 20 )
		local kickbuttonw, kickbuttonh = self.QKick.Button:GetPos()
		local kickiconsize = surface.GetTextureSize( surface.GetTextureID( kickicon ) )
		self.QKick.Button.Image:SetPos( 20, kickbuttonh - 5 )
		
		self.QKickDiv = self:Add("DPanel")
		self.QKickDiv:SetWide( sizew )
		self.QKickDiv:Dock( TOP )
		self.QKickDiv.Paint = function( pnl, w, h )
			surface.SetDrawColor( bgColor )
			surface.DrawRect( boxsizew, psizeh * 0.031, psizew - 10, psizeh)
		end
	end
	
	if LocalPlayer().PlayerInfo and LocalPlayer().PlayerInfo[ LocalPlayer() ]["perms"]["ban"] then
		self.QBanFake = self:Add("DPanel")
		self.QBanFake:SetWide( sizew )
		self.QBanFake:SetTall( self.QBanFake:GetTall() * 0.55 )
		self.QBanFake:Dock( TOP )
		self.QBanFake.Paint = function() end
	
		self.QBan = self:Add("DPanel")
		self.QBan:SetWide( sizew )
		self.QBan:SetTall( self.QBan:GetTall() - 1 )
		self.QBan:Dock( TOP )
		self.QBan.Paint = function() end
		
		self.QBan.Button = self.QBan:Add( "DButton" )
		self.QBan.Button:SetFont( "anus_BigTitle" )
		self.QBan.Button:SetText( banname )
		self.QBan.Button:SetTextColor( Color( 0, 120, 190, 255 ) )
		self.QBan.Button:AlignTop( banh * 0.35 )
		self.QBan.Button:AlignLeft( -10 )
		self.QBan.Button:Dock( FILL )
		self.QBan.Button:SetSize( (psizew * 0.5) - (groupw - banw), banh )
		self.QBan.Button.DoClick = function()
			RunConsoleCommand("say", "gotta ban fast")
		end
		anus_qban_menu = anus_qban_menu or nil
		local qban_menuw,qban_menuh = nil
		local qban_mousew,qban_mouseh = gui.MousePos()
		self.QBan.Button.Think = function( pnl )
			if pnl.Hovered then hovered = pnl end
			
			if hovered != pnl then
				if IsValid(anus_qban_menu) then
					anus_qban_menu:Remove()
					anus_qban_menu = nil
				end
			else
				if not IsValid(anus_qban_menu) then
					anus_qban_menu = vgui.Create("DMenu")
					local qbanw,qbanh = self.QBan:GetPos()
					anus_qban_menu:SetPos( psizew + (anus_qban_menu:GetWide() * 1.5), qbanh + 26 )
					qban_menuw,qban_menuh = anus_qban_menu:GetPos()
					
					anus_qban_menu:AddOption("Close", function()
						anus_qban_menu:Remove()
						anus_qban_menu = nil
						
						hovered = nil
						
						local pposw,pposh = self:GetPos()
						gui.SetMousePos( pposw, pposh )
					end):SetIcon( "icon16/cancel.png" )
					anus_qban_menu:AddSpacer()
					
					for i=1,#player.GetAll() do
						if not IsValid(player.GetAll()[ i ]) then continue end
						local ply = anus_qban_menu:AddSubMenu( player.GetAll()[ i ]:Nick(), function( this )
							if not IsValid( player.GetAll()[ i ] ) then return end
							if player.GetAll()[ i ]:IsBot() then
								RunConsoleCommand( "svanus_ban", player.GetAll()[ i ]:Nick() )
							else
								RunConsoleCommand( "svanus_ban", player.GetAll()[ i ]:SteamID() )
							end
							
							if IsValid(anus_qban_menu) then
								anus_qban_menu:Remove()
								anus_qban_menu = nil
								
								hovered = nil
								timer.Create("anus_reopenban", 0.118, 1, function()
									if not IsValid(anus_MainMenu) then return end
									hovered = pnl
								end)
							end
						end )
						
						local menu_tbl1 = {
							{["30 minutes"] = 30},
							{["1 hour"] = 60},
							{["12 hours"] = 60 * 12},
							{["1 day"] = 60 * 24},
							{["1 week"] = 60 * 24 * 7},
							{["Permanently"] = 0},
						}							
						
						local menu_tbl2 = {
							"General disruption.",
							"Mic spam.",
							"DISRESPECTFUL",
						}
						
						--PrintTable(menu_tbl1)
						
						--[[
						1:
								30 minutes	=	30
						2:
								1 hour	=	60
						3:
								12 hours	=	720
						4:
								1 day	=	1440
						5:
								1 week	=	10080
						6:
								Permanently	=	0]]
		
							-- get them in order
						for aa=1,#menu_tbl1 do
							local aaa = menu_tbl1[ aa ]
							
								-- string name, time
							for kk,vv in pairs( aaa ) do
								local plytime = ply:AddSubMenu( kk, function( this )
									if player.GetAll()[ i ]:IsBot() then
										RunConsoleCommand( "svanus_ban", player.GetAll()[ i ]:Nick(), vv )
									else
										RunConsoleCommand( "svanus_ban", player.GetAll()[ i ]:SteamID(), vv )
									end
							
									if IsValid(anus_qban_menu) then
										anus_qban_menu:Remove()
										anus_qban_menu = nil
								
										hovered = nil
										timer.Create("anus_reopenban", 0.118, 1, function()
											if not IsValid(anus_MainMenu) then return end
											hovered = pnl
										end)
									end
								end )
								
								for bb=1,#menu_tbl2 do
									local bbb = menu_tbl2[ bb ]
									
									plytime:AddOption( bbb, function()
										if not IsValid( player.GetAll()[ i ] ) then return end
										if player.GetAll()[ i ]:IsBot() then
											RunConsoleCommand( "svanus_ban", player.GetAll()[ i ]:Nick(), vv, bbb )
										else
											RunConsoleCommand( "svanus_ban", player.GetAll()[ i ]:SteamID(), vv, bbb )
										end
										
										if IsValid(anus_qban_menu) then
											anus_qban_menu:Remove()
											anus_qban_menu = nil
											
											hovered = nil
											timer.Create("anus_reopenban", 0.11, 1, function()
												if not IsValid(anus_MainMenu) then return end
												hovered = pnl
											end)
										end
									end ):SetIcon( LocalPlayer().PlayerInfo and LocalPlayer().PlayerInfo[ player.GetAll()[ i ] ] and anus.Groups[ LocalPlayer().PlayerInfo[ player.GetAll()[ i ] ]["group"] ].icon or "icon16/bullet_error.png" )
								end
							end
						end
					end
				end
			end
		end
		self.QBan.Button.Paint = function( pnl )
			if pnl.Hovered then
				--pnl:SetTextColor( Color( 191, 153, 96, 255 ) )
				pnl:SetTextColor( Color( 151, 191, 183, 255 ) )
			else
				--pnl:SetTextColor( Color( 128, 112, 89, 255 ) )
				pnl:SetTextColor( Color( 67, 132, 142, 255 ) )
			end
		end
		
		self.QBan.Button.Image = self.QBan.Button:Add( "DImage" )
		self.QBan.Button.Image:SetImage( banicon )
		self.QBan.Button.Image:SetSize( 20, 20 )
		local banbuttonw, banbuttonh = self.QBan.Button:GetPos()
		local baniconsize = surface.GetTextureSize( surface.GetTextureID( banicon ) )
		self.QBan.Button.Image:SetPos( 20, banbuttonh - 5 )
	end
end

function panel:Paint()
	draw.RoundedBox( 6, 0, 0, psizew, psizeh - 31, bgColor )
	draw.RoundedBox( 0, boxsizew, boxsizeh, psizew - 10 , psizeh - 42, Color( 241, 235, 209, 255 ) ) --Color( 230, 220, 207, 220 ) )
end

vgui.Register( "anus_mainmenu", panel )