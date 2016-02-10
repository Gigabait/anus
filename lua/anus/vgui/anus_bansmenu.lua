--------------------------------------------------------
--------------------------------------------------------
----------------
---------------- I'm so sorry who ever is reading this code, I literately cannot make menus for shit.
----------------
--------------------------------------------------------
--------------------------------------------------------

local panel = {}

--local psizew, psizeh = 450, 500
local psizew, psizeh = 520, 500
local boxpaddingw, boxpaddingh = 5, 5
function panel:Init()
	self:SetFocusTopLevel( true )
	self:SetSize( psizew, psizeh )
	self:SetPos( 400, 40 )
	self:MakePopup()
	
	self.Padding = self:Add("DPanel")
	self.Padding:SetWide( psizew )
	self.Padding:Dock( TOP )
	self.Padding.Paint = function() end
	
	self.MenuTitle = self:Add("DPanel")
	self.MenuTitle:SetWide( sizew )
	self.MenuTitle:SetTall( self.MenuTitle:GetTall() )
	self.MenuTitle:Dock( TOP )
	self.MenuTitle.Paint = function( pnl, w, h )
	end
	
	self.MenuTitle.Label = self.MenuTitle:Add( "DLabel" )
	self.MenuTitle.Label:SetText( "Modify Bans" )
	self.MenuTitle.Label:SetTextColor( Color( 0, 36, 60, 255 ) )
	self.MenuTitle.Label:Dock( FILL )
	self.MenuTitle.Label:SetFont( "anus_BigTitleFancy" )
	self.MenuTitle.Label:SetContentAlignment( 2 )
	self.MenuTitle.Label:SizeToContents()
	
	self.MenuTitle.Div = self:Add("DPanel")
	self.MenuTitle.Div:SetWide( sizew )
	self.MenuTitle.Div:Dock( TOP )
	self.MenuTitle.Div.Paint = function( pnl, w, h )
		surface.SetDrawColor( Color( 0, 60, 100, 255 ) )--Color( 0, 161, 255, 255 ) )--Color( 106, 102, 124, 255 ) )
			-- psizeh * 0.01
		surface.DrawRect( boxpaddingw, psizeh * 0.031, psizew - 10, psizeh)
	end
	
	self.Side = self:Add("DPanel")
	self.Side:SetWide( psizew * 0.15 )
	self.Side:Dock( LEFT )
	self.Side.Paint = function() end
	
	self.Side.CloseButton = self.Side:Add("DButton")
	self.Side.CloseButton:SetText( "" )
	self.Side.CloseButton:SetTall( psizeh * 0.7 )
	self.Side.CloseButton:Dock( TOP )
	self.Side.CloseButton.DoClick = function() self:Remove() end
	local titlelabel = self.MenuTitle.Label:GetTall()
	self.Side.CloseButton.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, boxpaddingw, 0, w, (psizeh - boxpaddingh) - (titlelabel * 4), Color( 195, 70, 70, 255 ) )
	end
	
	self.Side.AddBan = self.Side:Add("DButton")
	self.Side.AddBan:SetText( "" )
	--self.Side.AddBan:SetTall( psizeh * 0.1 )
	self.Side.AddBan:SetSize( 1, 10 )
	self.Side.AddBan:Dock( FILL )
	self.Side.AddBan.DoClick = function() end
	self.Side.AddBan.Paint = function( pnl, w, h ) 
		draw.RoundedBox( 0, boxpaddingw, 0, w, (psizeh * 0.3) - boxpaddingh - (titlelabel * 4), Color( 255, 255, 255, 255 ) )
		draw.DrawText( "Add Ban", "DermaDefault", 36, 15, Color( 105, 105, 105, 255 ), TEXT_ALIGN_CENTER )
	end
		-- have a dlistview of players
		-- when clicking a line, put their steamid in the box
		-- also have options to open profile, and copy steamid
		-- and then a button.
	self.Side.AddBan.DoClick = function( self )
		local unban_addban = vgui.Create("DFrame")
		unban_addban:SetTitle( "Add Ban")
		unban_addban:SetPos( psizew + 40, psizeh * 0.3 )
		unban_addban:SetSize( 400, 420 + boxpaddingh )
		unban_addban:SetDraggable( true )
		unban_addban:MakePopup()
		
		net.Start("anus_requestdc")
		net.SendToServer()
		
		local dcpanel = vgui.Create("DPanel", unban_addban)
		dcpanel:SetPos( 5, 25 + boxpaddingh )
		local dcpanelw,dcpanelh = 400 - boxpaddingw*2, 400 - 10
		dcpanel:SetTall( dcpanelh )
		dcpanel:SetWide( dcpanelw )
		
			-- sorry it's a clusterfuck, the rest of the code is below this behemoth
		local dctext = vgui.Create("DTextEntry", dcpanel)
		
		--{name = pl:Nick(), kills = pl:Frags(), hour = os.date("%H"), minute = os.date("%M"), second = os.date("%S")}
		local dclist = vgui.Create("DListView", dcpanel)
		dclist:SetMultiSelect( false )
		local dclistsizew = 400 - boxpaddingw*2
		dclist:SetSize( dclistsizew, dcpanelh * 0.93 )
		dclist:AddColumn( "SteamID" )
		dclist.Columns[ 1 ]:SetFixedWidth( 1 )
		--dclist.Columns[ 1 ]:SetWide( 1 )
		dclist:AddColumn( "Disconnected Player" )
		dclist.Columns[ 2 ]:SetFixedWidth( dclistsizew * 0.5 )
		dclist:AddColumn( "Kills" )
		dclist:AddColumn( "Time" )
		dclist:Clear()
		timer.Simple(0.1, function()
			local offset = 0
			if anus.ServerHour and tonumber(os.date("%H")) < anus.ServerHour then offset = anus.ServerHour - tonumber(os.date("%H")) end
			print("servers hour is " .. anus.ServerHour .. ",,, client hour is " .. os.date("%H"))
			if table.Count(anus.PlayerDC) > 0 then
				for k,v in pairs(anus.PlayerDC) do
					dclist:AddLine( k, v.name, v.kills, v.hour - offset .. ":" .. v.minute .. ":" .. v.second )
				end
			end
		end)
		dclist.OnClickLine = function( parent, line, bSelected )
			dctext:SetText( line:GetValue( 1 ) )
		end
		dclist.OnRowRightClick = function( parent, lineid, line )
			local addban_options = DermaMenu()
			addban_options:AddOption( "Close", function() end )
			addban_options:AddOption( "View Profile", function() gui.OpenURL("http://steamcommunity.com/profiles/" .. util.SteamIDTo64( line:GetValue( 1 ) )) end )
			for i=1, #line:GetListView().Columns do
				local v = line:GetListView().Columns[ i ]
				print( v.Header:GetText() )
				addban_options:AddOption( "Copy " .. v.Header:GetText(), function() 
					SetClipboardText( line:GetValue( i ) )
				end )
			end
				
			addban_options:Open()
		end

		dctext:SetText( "STEAM_0:" )
		dctext:SetSize( dcpanelw * 0.35, 20 )
		dctext:SetPos( dcpanel:GetWide() * 0.1, dcpanel:GetTall() * 0.94 )
		
		local dcbutton = vgui.Create("DButton", dcpanel)
		dcbutton:SetText( "Add ban" )
		dcbutton:SetSize( dcpanelw * 0.4, 20 )
		dcbutton:SetPos( dcpanel:GetWide() * 0.5, dcpanel:GetTall() * 0.94 )
		dcbutton.DoClick = function()
			RunConsoleCommand("anus_banid", dctext:GetValue())
		end
		
		
		
	end
	
	net.Start("anus_requestbans")
	net.SendToServer()
	
	self.Content = self:Add("DPanel")
	self.Content:SetTall( psizeh - (psizeh * 0.21) - boxpaddingh + 1 )
	self.Content:Dock( TOP )
	self.Content.Paint = function() end
	
	self.Content.PaddingRight = self.Content:Add("DPanel")
	self.Content.PaddingRight:SetTall( psizeh )
	self.Content.PaddingRight:SetWide( boxpaddingw )
	self.Content.PaddingRight:Dock( RIGHT )
	self.Content.PaddingRight.Paint = function() end

	self.Content.ContentInfo = self.Content:Add("DListView")
	self.Content.ContentInfo:SetMultiSelect( false )
	self.Content.ContentInfo:Dock( FILL )
	self.Content.ContentInfo:AddColumn( "Player" )
	self.Content.ContentInfo:AddColumn( "Admin" )
	self.Content.ContentInfo:AddColumn( "Time left" )
	self.Content.ContentInfo:AddColumn( "Reason" )
	
	hook.Add("OnBanlistChanged", "anus_BanlistRefresh", function()
		if not self.Content then return end
			
		self.Content.ContentInfo:Clear()
		timer.Simple(0.1, function()
			if table.Count(anus.Bans) > 0 then
				for k,v in pairs(anus.Bans) do
					self.Content.ContentInfo:AddLine( v.name, v.admin, (v.time and tonumber(v.time) != 0 and os.date( "%Y/%m/%d %H:%M:%S", v.time ) or "Never"), v.reason )
					self.Content.ContentInfo.OnClickLine = function( parent2, line, b_selected2 )
						self.Content.ContentInfo:ClearSelection()
						line:SetSelected( true )
						line.m_fClickTime = SysTime()
						self.Content.ContentInfo:OnRowSelected( line:GetID(), line )
					end
					self.Content.ContentInfo.OnRowRightClick = function( parent2, lineid, line )
						local unban_options = DermaMenu()
						unban_options:AddOption( "Close", function() end )
						unban_options:AddOption( "Open Profile", function() print(util.SteamIDTo64(k)) gui.OpenURL("http://steamcommunity.com/profiles/" .. util.SteamIDTo64( k )) end )
						unban_options:AddOption( "Remove ban", function() Derma_StringRequest( "Confirm unbanning " .. v.name .. " (" .. k .. ")", "Confirm the unban?", "",
							function() RunConsoleCommand("anus_unban", k) end,
							function() end )
						end )
						unban_options:Open()
					end
				end
			end	
		end)
	end)
end

function panel:Paint()
	draw.RoundedBox( 6, 0, 0, psizew, psizeh - 31, Color( 0, 60, 100, 255 ) )--Color( 106, 102, 124, 220 ) )
	draw.RoundedBox( 0, boxpaddingw, boxpaddingh, psizew - 10 , psizeh - 42, Color( 240, 240, 240, 220 ) )
end

--[[surface.SetFont( "anus_BansTitle" )
local title_name = "Modify Bans"
local titlesizew, titlesizeh = surface.GetTextSize( title_name )
function panel:PaintOver()
	/*draw.RoundedBox( 0, 50, boxsizeh, psizew - 10 , psizeh - 42, Color( 244, 240, 240, 220 ) )
	surface.SetFont( "anus_BansTitle" )
	surface.SetTextColor( Color( 0, 36, 60, 255 ) )
	surface.SetTextPos( 25, 20 )*/
	
	draw.DrawText( title_name, "anus_BansTitle", ( (titlesizew / 2) + psizew) * 0.5, 50, Color( 0, 36, 60, 255 ), TEXT_ALIGN_CENTER )
end]]

vgui.Register( "anus_bansmenu", panel )