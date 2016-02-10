--------------------------------------------------------
--------------------------------------------------------
----------------
---------------- I'm so sorry who ever is reading this code, I literately cannot make menus for shit.
----------------
--------------------------------------------------------
--------------------------------------------------------

-- todo: add a hook similar to the OnBanListchanged hook
-- yes

local panel = {}

--local psizew, psizeh = 450, 500
local psizew, psizeh = 550, 600
local boxpaddingw, boxpaddingh = 5, 5
local side_width = psizew * 0.3
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
	self.MenuTitle.Label:SetText( "Modify Groups" )
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
	self.Side:SetWide( side_width )
	self.Side:Dock( LEFT )
	self.Side.Paint = function() end
	
	self.Side.CloseButton = self.Side:Add("DButton")
	self.Side.CloseButton:SetText( "" )
	self.Side.CloseButton:SetWide( psisew )
	self.Side.CloseButton:SetTall( psizeh * 0.13 )
	self.Side.CloseButton:Dock( TOP )
	self.Side.CloseButton.DoClick = function() self:Remove() end
	local titlelabel = self.MenuTitle.Label:GetTall()
	local closebuttonx,closebuttony = self.Side.CloseButton:GetPos()
	local closebuttonsizex, closebuttonsizey = self.Side.CloseButton:GetSize()
	surface.SetFont("anus_SmallTitle")
	local closetextw,closetexth = surface.GetTextSize( "CLOSE" )
	self.Side.CloseButton.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, boxpaddingw, 0, w, (psizeh - boxpaddingh) - (titlelabel * 4), Color( 195, 70, 70, 255 ) )
		draw.DrawText( "CLOSE", "anus_SmallTitle", (closebuttonsizex / 2) + closetextw + (boxpaddingw * 4) + 1, (h / 2) - (closetexth / 2), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end
	
	self.Side.Panel = self.Side:Add("DPanel")
	self.Side.Panel:SetTall( psizeh * 0.695 - boxpaddingh)
	self.Side.Panel:Dock( TOP )
	self.Side.Panel:SetPos( 50, 100 )
	self.Side.Panel.Paint = function() end
	
	local combobox_offset = 5
	
	self.Side.Panel.Groups = self.Side.Panel:Add("DComboBox")
	self.Side.Panel.Groups:SetPos( boxpaddingw, combobox_offset )
		-- todo: no hardcoding?
	self.Side.Panel.Groups:SetWide( 160 )
	self.Side.Panel.Groups:SetValue( "user" )
	--self.Side.Panel.Groups:Dock( TOP )
	for groups,v in SortedPairsByMemberValue( anus.Groups, "id", false ) do
		self.Side.Panel.Groups:AddChoice( groups )
		self.Side.Panel.Groups.OnSelect = function( pnl, index, value )
			self.Side.Panel.PlayerList:Clear()
			if anus.Users and anus.Users[ value ] then
				for k,v in pairs(anus.Users[ value ]) do
					self.Side.Panel.PlayerList:AddLine( k, v.name )
				end
			elseif value == "user" then
				for k,v in pairs(player.GetAll()) do
					if not LocalPlayer().PlayerInfo or not LocalPlayer().PlayerInfo[ v ] then
						self.Side.Panel.PlayerList:AddLine( v:SteamID(), v:Nick() )
					end
				end
			end
					
		end
	end
	--self.Side.Panel.Groups:AddChoice( "Manage Groups" )
	
	net.Start("anus_requestusers")
	net.SendToServer()
	
	self.Side.Panel.PlayerList = self.Side.Panel:Add("DListView")
	self.Side.Panel.PlayerList:SetSize( self.Side:GetWide() - boxpaddingw, psizeh * 0.5 )
		-- 22 is combo box height
	self.Side.Panel.PlayerList:SetPos( boxpaddingw, 22 + combobox_offset )
		-- maybe make it true later.
	self.Side.Panel.PlayerList:SetMultiSelect( false )
	self.Side.Panel.PlayerList:AddColumn( "Player SteamID" )
	self.Side.Panel.PlayerList.Columns[ 1 ]:SetFixedWidth( 1 )
	self.Side.Panel.PlayerList:AddColumn( "Players in Group" )
	
	self.Side.Panel.ChangeGroup = self.Side.Panel:Add("DButton")
	
	hook.Add("OnPlayerGroupsChanged", "anus_PlayerInGroupsRefresh", function()
		if not anus_GroupsMenu or not IsValid(anus_GroupsMenu) then return end

		self.Side.Panel.PlayerList:Clear()
	
			-- loop through current group selected
		if self.Side.Panel.Groups:GetValue() == "user" then
			for k,v in pairs(player.GetAll()) do
				if not LocalPlayer().PlayerInfo or not LocalPlayer().PlayerInfo[ v ] then
					self.Side.Panel.PlayerList:AddLine( v:SteamID(), v:Nick() )
				end
			end
		else
			if anus.Users and anus.Users[ self.Side.Panel.Groups:GetValue() ] then
				for k,v in pairs(anus.Users[ self.Side.Panel.Groups:GetValue() ]) do
					self.Side.Panel.PlayerList:AddLine( k, v.name )
				end
			end
		end

		self.Side.Panel.PlayerList.OnRowRightClick = function( parent, lineid, line )
			local playerlist = DermaMenu()
			playerlist:AddOption( "Close", function() end )
			playerlist:AddOption( "Update Name", function() line:SetValue( 2, steamworks.GetPlayerName( util.SteamIDTo64( line:GetValue( 1 ) ) ) ) end )
			playerlist:AddOption( "View Promotion Date", function() LocalPlayer():ChatPrint( line:GetValue(2) .. " was set to " .. self.Side.Panel.Groups:GetValue() .. " on ................" ) end )
			playerlist:AddOption( "View Profile", function() gui.OpenURL("http://steamcommunity.com/profiles/" .. util.SteamIDTo64( line:GetValue( 1 ) )) end )
				-- might be useful idk
			playerlist:AddOption( "Copy SteamID", function() SetClipboardText( line:GetValue( 1 ) ) end )
				
			playerlist:Open()
		end

		self.Side.Panel.ChangeGroup:SetText( "Change" )
		local listx,listy = self.Side.Panel.PlayerList:GetPos()
		local listw,listh = self.Side.Panel.PlayerList:GetSize()
		self.Side.Panel.ChangeGroup:SetPos( boxpaddingw, listh + listy )
		self.Side.Panel.ChangeGroup:SetSize( self.Side:GetWide() - boxpaddingw, 20 )
		self.Side.Panel.ChangeGroup.DoClick = function()
			if not self.Side.Panel.PlayerList:GetSelectedLine() then print("grrr") return end
			local playerline = self.Side.Panel.PlayerList:GetLine( self.Side.Panel.PlayerList:GetSelectedLine() )
			
			local groupslist = DermaMenu()
			groupslist:AddOption( "Close", function() end )
			groupslist:AddSpacer()
			for k,v in SortedPairsByMemberValue( anus.Groups, "id", false ) do
				groupslist:AddOption( k, function()
					local found = false
					for _,v in pairs(player.GetAll()) do
						if v:SteamID() == playerline:GetValue( 1 ) then
							print("player is in the server - anus_adduser")
							RunConsoleCommand("anus_adduser", tostring(playerline:GetValue(1)), k)
						
							found = true
							break
						end
					end
					
					if not found then
						print("player isnt in server - anus_adduserid")
						RunConsoleCommand("anus_adduserid", tostring(playerline:GetValue(1)), k)
					end
				end )
				
			end
			
			groupslist:Open()
		end
	end)
	
	self.Side.Panel.Apply = self.Side.Panel:Add("DButton")
	self.Side.Panel.Apply:SetText( "Apply Changes" )
	local changex,changey = self.Side.Panel.ChangeGroup:GetPos()
	self.Side.Panel.Apply:SetPos( boxpaddingw, self.Side.Panel:GetTall() - 39 )
	self.Side.Panel.Apply:SetSize( self.Side:GetWide() - boxpaddingw, 40 )
	
	local titleLabel = self.MenuTitle.Label:GetTall()
	
	self.Content = self:Add("DPanel")
	self.Content:SetWide( psizew - side_width )
	self.Content:Dock( LEFT )
	self.Content.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, boxpaddingw, 0, w, (psizeh - boxpaddingh) - (titleLabel * 4), Color( 0, 60, 100, 255 ) )
	end
	
	self.Content.Categories = self.Content.Categories or {}
	self.Content.SubCategories = self.Content.SubCategories or {}
	--[[for k,v in SortedPairs( LocalPlayer().PlayerInfo[ LocalPlayer() ]["perms"] ) do
		if not anus.Plugins[ k ] then continue end
		if anus.Plugins[ k ].nomenu then continue end
		
		local category = anus.Plugins[ k ].category or "Other"
		if not self.Content.Categories[ category ] then
			
			self.Content.Categories[ category ] = self.Content:Add("DCollapsibleCategory")
			self.Content.Categories[ category ]:SetLabel( category )
			self.Content.Categories[ category ]:SetExpanded( 0 )
			self.Content.Categories[ category ]:SetSize( psize, psizeh * 0.2 )
			self.Content.Categories[ category ]:Dock( TOP )
			self.Content.Categories[ category ].Paint = function( pnl, w, h )
				derma.SkinHook( "Anus", "CollapsibleCategory", pnl, w, h )
			end
			
			self.Content.Categories[ category ].Header:SetSize( 30, 40 )
			self.Content.Categories[ category ].Header:SetFont( "anus_SmallTitle" )
			self.Content.Categories[ category ].CatName = category
			self.Content.Categories[ category ].Header.DoClick = function( pnl )
				self.Content.Categories[ category ]:Toggle()

				for a,b in pairs(self.Content.Categories) do
					if a == pnl:GetParent().CatName then continue end
						
					self.Content.Categories[ a ]:SetExpanded( false )
					self.Content.Categories[ a ].animSlide:Start( self.Content.Categories[ a ]:GetAnimTime(),{ From = self.Content.Categories[ a ]:GetTall() } )
					self.Content.Categories[ a]:InvalidateLayout( true )
					self.Content.Categories[ a ]:GetParent():InvalidateLayout()
					self.Content.Categories[ a ]:GetParent():GetParent():InvalidateLayout()
						
					self.Content.Categories[ a ]:SetCookie( "Open", "0" )
				end
			end
		end
	end]]

	-- on click main content categories, close all sub categories of other and close main. pretty obvious
	-- on click main category, create white panel background, then more blue sub categories
	
	self.Content.Categories[ "RESTRICTIONS" ] = self.Content:Add("DCollapsibleCategory")
	self.Content.Categories[ "RESTRICTIONS" ]:SetLabel( "RESTRICTIONS" )
	self.Content.Categories[ "RESTRICTIONS" ]:SetExpanded( 0 )
	self.Content.Categories[ "RESTRICTIONS" ]:SetSize( psize, psizeh * 0.2 )
	self.Content.Categories[ "RESTRICTIONS" ]:Dock( TOP )
	self.Content.Categories[ "RESTRICTIONS" ].Paint = function( pnl, w, h )
		derma.SkinHook( "Anus", "CollapsibleCategory", pnl, w, h )
	end
	self.Content.Categories[ "RESTRICTIONS" ].Header:SetSize( 30, 40 )
	self.Content.Categories[ "RESTRICTIONS" ].Header:SetFont( "anus_BigTitle" )
	self.Content.Categories[ "RESTRICTIONS" ].Header:SetContentAlignment( 2 )
	self.Content.Categories[ "RESTRICTIONS" ].Header.DoClick = function( pnl )
		self.Content.Categories[ "RESTRICTIONS" ]:Toggle()

		self.Content.Categories[ "PLUGINS" ]:SetExpanded( false )
		self.Content.Categories[ "PLUGINS" ].animSlide:Start( self.Content.Categories[ "PLUGINS" ]:GetAnimTime(),{ From = self.Content.Categories[ "PLUGINS" ]:GetTall() } )
		self.Content.Categories[ "PLUGINS" ]:InvalidateLayout( true )
		self.Content.Categories[ "PLUGINS" ]:GetParent():InvalidateLayout()
		self.Content.Categories[ "PLUGINS" ]:GetParent():GetParent():InvalidateLayout()
						
		self.Content.Categories[ "PLUGINS" ]:SetCookie( "Open", "0" )
	end
	--lua_run_cl PrintTable(list.Get("Weapon"))
	
	
	self.Content.Categories[ "PLUGINS" ] = self.Content:Add("DCollapsibleCategory")
	self.Content.Categories[ "PLUGINS" ]:SetLabel( "PLUGINS" )
	self.Content.Categories[ "PLUGINS" ]:SetExpanded( 0 )
	self.Content.Categories[ "PLUGINS" ]:SetSize( psize, psizeh * 0.2 )
	self.Content.Categories[ "PLUGINS" ]:Dock( TOP )
	self.Content.Categories[ "PLUGINS" ].Paint = function( pnl, w, h )
		derma.SkinHook( "Anus", "CollapsibleCategory", pnl, w, h )
	end
	
	self.Content.Categories[ "PLUGINS" ].Header:SetSize( 30, 40 )
	self.Content.Categories[ "PLUGINS" ].Header:SetFont( "anus_BigTitle" )
	self.Content.Categories[ "PLUGINS" ].Header:SetContentAlignment( 2 )
	self.Content.Categories[ "PLUGINS" ].Header.DoClick = function( pnl )
		self.Content.Categories[ "PLUGINS" ]:Toggle()

		self.Content.Categories[ "RESTRICTIONS" ]:SetExpanded( false )
		self.Content.Categories[ "RESTRICTIONS" ].animSlide:Start( self.Content.Categories[ "RESTRICTIONS" ]:GetAnimTime(),{ From = self.Content.Categories[ "RESTRICTIONS" ]:GetTall() } )
		self.Content.Categories[ "RESTRICTIONS" ]:InvalidateLayout( true )
		self.Content.Categories[ "RESTRICTIONS" ]:GetParent():InvalidateLayout()
		self.Content.Categories[ "RESTRICTIONS" ]:GetParent():GetParent():InvalidateLayout()
						
		self.Content.Categories[ "RESTRICTIONS" ]:SetCookie( "Open", "0" )
	end
	self.Content.Categories[ "PLUGINS" ].Panel = self.Content.Categories[ "PLUGINS" ]:Add( "DPanel" )
	self.Content.Categories[ "PLUGINS" ].Panel:SetText( "" )
	self.Content.Categories[ "PLUGINS" ].Panel:SetWide( psizew - boxpaddingw )
	self.Content.Categories[ "PLUGINS" ].Panel:SetTall( psizeh * 0.15 )
	print(titleLabel * 4, "test" )
	self.Content.Categories[ "PLUGINS" ].Panel:SetSize( psizew - boxpaddingw, psizeh - (titleLabel * 4) - (self.Content.Categories[ "RESTRICTIONS" ]:GetTall() - titleLabel) + boxpaddingh - 1 )
	self.Content.Categories[ "PLUGINS" ].Panel:Dock( TOP )
	self.Content.Categories[ "PLUGINS" ].Panel.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, psizew - self.Side:GetWide() - boxpaddingw, psizeh, Color( 240, 240, 240, 255 ) )
	end
	
	self.Content.Categories[ "PLUGINS"].Panel.PanelFake = self.Content.Categories[ "PLUGINS" ].Panel:Add( "DPanel" )
	self.Content.Categories[ "PLUGINS"].Panel.PanelFake:SetWide( psizew - boxpaddingw )
	self.Content.Categories[ "PLUGINS"].Panel.PanelFake:SetTall( 5 )
	self.Content.Categories[ "PLUGINS"].Panel.PanelFake:SetSize( psizew - boxpaddingw, 5 )
	self.Content.Categories[ "PLUGINS"].Panel.PanelFake:Dock( TOP )
	self.Content.Categories[ "PLUGINS"].Panel.PanelFake.Paint = function() end
	
	--for k,v in SortedPairs( LocalPlayer().PlayerInfo[ LocalPlayer() ]["perms"] ) do
	for k,v in SortedPairs(anus.Plugins) do
		if not anus.Plugins[ k ] then continue end
		if anus.Plugins[ k ].nomenu then continue end
		
		local category = anus.Plugins[ k ].category or "Other"
		if not self.Content.SubCategories[ category ] then
			self.Content.SubCategories[ category ] = self.Content.Categories[ "PLUGINS" ].Panel:Add("DCollapsibleCategory")
			self.Content.SubCategories[ category ]:SetLabel( category )
			self.Content.SubCategories[ category ]:SetExpanded( 0 )
			self.Content.SubCategories[ category ]:SetSize( psizew, psizeh * 0.2 )
			self.Content.SubCategories[ category ]:Dock( TOP )
			self.Content.SubCategories[ category ].Paint = function( pnl, w, h )
				derma.SkinHook( "Anus", "CollapsibleCategory", pnl, w, h )
				draw.RoundedBox( 2, boxpaddingw + 20, 0, w - 40 - (boxpaddingw*2), psizeh - boxpaddingh - (titleLabel * 4 ), Color( 0, 60, 100, 255 ) )
				--print("hELLO", w - 40 - (boxpaddingw*2))
			end
			
			self.Content.SubCategories[ category ].Header:SetSize( 30, 40 )
			self.Content.SubCategories[ category ].Header:SetFont( "anus_SmallTitle" )
			self.Content.SubCategories[ category ].Header:SetContentAlignment( 2 )
			self.Content.SubCategories[ category ].CatName = category
			self.Content.SubCategories[ category ].Header.DoClick = function( pnl )
				self.Content.SubCategories[ category ]:Toggle()
				
				for a,b in pairs(self.Content.SubCategories) do
					if a == pnl:GetParent().CatName then continue end
						
					self.Content.SubCategories[ a ]:SetExpanded( false )
					self.Content.SubCategories[ a ].animSlide:Start( self.Content.SubCategories[ a ]:GetAnimTime(),{ From = self.Content.SubCategories[ a ]:GetTall() } )
					self.Content.SubCategories[ a ]:InvalidateLayout( true )
					self.Content.SubCategories[ a ]:GetParent():InvalidateLayout()
					self.Content.SubCategories[ a ]:GetParent():GetParent():InvalidateLayout()
						
					self.Content.SubCategories[ a ]:SetCookie( "Open", "0" )
				end
			end
			
				-- fuck repeated typing
			local subcat = self.Content.SubCategories[ category ]
			local subcat_w, subcat_h = subcat:GetSize()
			subcat.Panel = subcat:Add( "DPanel" )
			subcat.Panel:SetText( "" )
			subcat.Panel:SetWide( 3 )
			subcat.Panel:SetTall( psizeh * 0.15 )
			subcat.Panel:SetSize( 3, psizeh * 0.21 )
			subcat.Panel:Dock( TOP )
			subcat.Panel.Paint = function() end
			
			local subcat_panel_x, subcat_panel_y = subcat.Panel:GetPos()
			
			subcat.Panel.Layout = subcat.Panel:Add("DListView")
			subcat.Panel.Layout.LineCount = 1
			subcat.Panel.Layout:SetHideHeaders( true )
			local subcatpanellayout_x,subcatpanellayout_y = subcat.Panel.Layout:GetPos()
			subcat.Panel.Layout:SetPos( boxpaddingw + 20, subcatpanellayout_y )
			local subcatpanellayout_w = 383 - 40 - (boxpaddingw*2) - 2
			subcat.Panel.Layout:SetSize( subcatpanellayout_w, psizeh * 0.21 )
			subcat.Panel.Layout:SetMultiSelect( false )
			subcat.Panel.Layout:AddColumn("Plugin")
			subcat.Panel.Layout.AddLine = function( self2, ... )
				subcat.Panel.Layout:SetDirty( true )
				subcat.Panel.Layout:InvalidateLayout()

				local Line = vgui.Create( "DListView_Line", subcat.Panel.Layout.pnlCanvas )
				local ID = table.insert( subcat.Panel.Layout.Lines, Line )
	
				Line:SetListView( subcat.Panel.Layout ) 
				Line:SetID( ID )
	
				-- This assures that there will be an entry for every column
				for k, v in pairs( subcat.Panel.Layout.Columns ) do
					Line:SetColumnText( k, "" )
				end

				local addline_args = {...}
				for k, v in pairs( addline_args ) do
					Line:SetColumnText( k, v )
					
					subcat.Panel.Checkbox = subcat.Panel.Checkbox or {}
				
					subcat.Panel.Checkbox[ subcat.Panel.Layout.LineCount ] = subcat.Panel:Add("DCheckBox")
					subcat.Panel.Checkbox[ subcat.Panel.Layout.LineCount ].Parent = v
					print("parent is ", k )
					if subcat.Panel.Layout.LineCount == 1 then
						subcat.Panel.Checkbox[ subcat.Panel.Layout.LineCount ]:SetPos( subcatpanellayout_w, subcatpanellayout_y + ( 1 ) )
					else
						subcat.Panel.Checkbox[ subcat.Panel.Layout.LineCount ]:SetPos( subcatpanellayout_w, subcatpanellayout_y + ( 17 * (subcat.Panel.Layout.LineCount - 1)) )
					end
					subcat.Panel.Checkbox[ subcat.Panel.Layout.LineCount ].DoClick = function( pnl )
						pnl:Toggle()
						print(pnl.Parent)
					end
					print("oh shit son", self.Side.Panel.Groups:GetValue(), anus.Groups[ self.Side.Panel.Groups:GetValue() ].Permissions[ v ])
					if anus.Groups[ self.Side.Panel.Groups:GetValue() ].Permissions[ v ] then
						subcat.Panel.Checkbox[ subcat.Panel.Layout.LineCount ]:SetValue( 1 )
					end
				end
	
				-- Make appear at the bottom of the sorted list
				local SortID = table.insert( subcat.Panel.Layout.Sorted, Line )
	
				if ( SortID % 2 == 1 ) then
					Line:SetAltLine( true )
				end

				subcat.Panel.Layout.LineCount = subcat.Panel.Layout.LineCount + 1
				subcat.Panel:SetSize( 3, 17 * (subcat.Panel.Layout.LineCount - 1) )---psizeh * 0.21 + (self.Sidebar[ category ].Panel.Layout.LineCount * 4.3) )
				subcat.Panel.Layout:SetSize( subcatpanellayout_w * 0.9, 17 * subcat.Panel.Layout.LineCount )--psizeh * 0.21 + (self.Sidebar[ category ].Panel.Layout.LineCount * 4.3) )
				
				
				--subcat.Panel.Checkbox[ subcat.Panel.Layout.LineCount - 1 ]:SetPos( subcatpanellayout_w, subcatpanellayout_y + ( (subcat.Panel.Layout.LineCount - 1 == 1 and 1 or 18) * (subcat.Panel.Layout.LineCount - 1)) )--(tonumber( "1." .. subcat.Panel.Layout.LineCount)))
				
				return Line
			end
			
			
			subcat.Panel.Layout:AddLine( k )
			
		else
		
			local subcat = self.Content.SubCategories[ category ]
			subcat.Panel.Layout:AddLine( k )
		
		end
	end
	
	
			
end

function panel:Paint()
	draw.RoundedBox( 6, 0, 0, psizew, psizeh - 31, Color( 0, 60, 100, 255 ) )--Color( 106, 102, 124, 220 ) )
	draw.RoundedBox( 0, boxpaddingw, boxpaddingh, psizew - 10 , psizeh - 42, Color( 240, 240, 240, 220 ) )
end

vgui.Register( "anus_groupsmenu", panel )