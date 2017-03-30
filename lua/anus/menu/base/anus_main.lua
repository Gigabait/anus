local Panel = {}

surface.CreateFont( "anus_SmallTitle",
{
	font = "Verdana",
	size = 21,
} )
surface.CreateFont( "anus_SmallTitleHeavy",
{
	font = "Verdana",
	weight = 900,
	size = 21,
} )
surface.CreateFont( "anus_SmallTitleBolded",
{
	font = "Verdana",
	weight = 610,
	size = 18,
} )
surface.CreateFont( "anus_MediumTitle",
{
	font = "Verdana",
	weight = 900,
	size = 23,
} )
surface.CreateFont( "anus_BigTitle",
{
	font = "Verdana",
	size = 26,
} )


ANUS_MENUWIDE, ANUS_MENUTALL = math.max( 840, ScrW() * 0.6667 ), math.max( 555, ScrH() * 0.711 )
ANUS_MENUALPHA = 255
local BgColor = Color( 231, 230, 237, ANUS_MENUALPHA )
local DrawRoundedBox = draw.RoundedBox

function Panel:Init()
	self.openedCategory = nil
	self.openedCategoryCatID = nil
	self.storedCategories = {}
	self.storedContent = {}

	self:SetSize( ANUS_MENUWIDE, ANUS_MENUTALL )
	self:Center()
	self:MakePopup()
	timer.Simple( 0.1, function()
		if not IsValid( self ) then return end
		self:SetKeyboardInputEnabled( false )
	end )
	
	self.Categories = self:Add( "anus_scrollpanel" )
	self.Categories:SetWide( ANUS_MENUWIDE * 0.172 )
	self.Categories:SetVerticalScrollbarEnabled( true )
	self.Categories.VBar:SetWide( 0 ) 
	self.Categories:Dock( LEFT )
	self.Categories.Paint = function( pnl, w, h )
		--DrawRoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, ANUS_MENUALPHA ) )
	end
	
	self.Top = self:Add( "DPanel" )
	self.Top:SetTall( 20 )
	self.Top:Dock( TOP )
	self.Top.Paint = function() end
	
	self.CloseButton = self.Top:Add( "anus_button" )
	self.CloseButton:SetText( "X" )
	self.CloseButton:SetWide( 25 )
	self.CloseButton:Dock( RIGHT )
	self.CloseButton.Paint = function() end
	self.CloseButton.DoClick = function()
		--anus_mainMenu:Hide()
		anus_mainMenu:SetVisible( false )
		gui.EnableScreenClicker( false )
	end

	self.Content = self:Add( "DPanel" )
	self.Content:Dock( FILL )
	self.Content:DockMargin( 20, 0, 20, 20 )
	self.Content.Paint = function( pnl, w, h )
		--DrawRoundedBox( 0, 0, 0, w, h, Color( 100, 20, 20, ANUS_MENUALPHA ) )
	end
	
	self.allowCategoryClicks = true
	hook.Add( "anus_StartMenuLoadingContent", self, function()
		self.allowCategoryClicks = false
	end )
	hook.Add( "anus_FinishMenuLoadingContent", self, function()
		self.allowCategoryClicks = true
	end )
	
	self:Refresh()
	
	timer.Create( "anus_CheckTextEntry" .. tostring( self ), 0.35, 1, function()
		if not anus_mainMenu or not IsValid( anus_mainMenu ) then return end

		hook.Add( "OnTextEntryGetFocus", anus_mainMenu, function( pnl )
			anus_mainMenu:SetKeyboardInputEnabled( true )
		end )
		hook.Add( "OnTextEntryLoseFocus", anus_mainMenu, function( pnl )
			anus_mainMenu:SetKeyboardInputEnabled( false )
		end )

		hook.Add( "StartChat", anus_mainMenu, function()
			anus_mainMenu.ChatBoxOpen = true
			ANUS_MENUALPHA = 50
		end )
		hook.Add( "FinishChat", anus_mainMenu, function() 
			anus_mainMenu.ChatBoxOpen = false
			ANUS_MENUALPHA = 255
		end )
		
		hook.Add( "anus_LocalPlayerDataChanged", anus_mainMenu, function()
			self:Refresh()
		end )
	end ) 
end

local function CreateAnonymousPanel()
	local Pnl = vgui.Create( "DPanel" )
	Pnl:SetSize( 0, 0 )
	Pnl:SetPos( 0, 0 )
	--Pnl:Hide()
	Pnl:SetVisible( false )

	return Pnl
end

function Panel:Refresh()
	self.Categories:Clear()
	self.Content:Clear()
	self.openedCategory = nil
	--self.openedCategoryCatID = nil
	for k,v in next, self.storedCategories do
		v:Remove()
		self.storedCategories[ k ] = nil
	end
	for k,v in next, self.storedContent do
		v:Remove()
		self.storedContent[ k ] = nil
	end

	local MenuCategories = table.GetKeys( anus.menuCategories or {} )
	table.sort( MenuCategories, function( a, b )
		return tostring( a ) < tostring( b )
	end )

	for i=1,#MenuCategories do
		local k = MenuCategories[ i ]
		local v = anus.menuCategories[ k ]
		
		if v.pluginid then --and not LocalPlayer():hasAccess( v.pluginid ) then
			local HasAccess = false
			if istable( v.pluginid ) then
				for _,access in ipairs( v.pluginid ) do
					if LocalPlayer():hasAccess( access ) then
						HasAccess = true
						break
					end
				end
			else
				if LocalPlayer():hasAccess( v.pluginid ) then
					HasAccess = true
				end
			end
			
			if HasAccess then goto breakout end
			
			if self.storedCategories[ v.pluginid ] then
				self.storedCategories[ v.pluginid ]:Remove()
				self.storedCategories[ v.pluginid ] = nil
			end

			if self.storedContent[ v.pluginid ] then
				self.storedContent[ v.pluginid ]:Remove()
				self.storedContent[ v.pluginid ] = nil
			end

			continue
		end

		::breakout::

			-- remnant from last menu,
			-- SHINYCOW: what is its use?
		--[[if v.pluginid and anus.isPluginDisabled( v.pluginid ) then
			self.pluginsCache = self.pluginsCache or {}
			self.pluginsCache[ v.pluginid ] = true
		end]]
		
		if v.pluginid and (not istable( v.pluginid )) and anus.isPluginDisabled( v.pluginid ) then
			continue
		end

		local CatID = v.pluginid or string.format( "NOPLUGINID_%s", k )

		self.storedCategories[ CatID ] = self.Categories:Add( "DButton" )
		self.storedCategories[ CatID ]:SetText( k or "Unknown" )
		self.storedCategories[ CatID ]:SetFont( "anus_SmallTitle" )
		self.storedCategories[ CatID ]:SetTall( ANUS_MENUTALL / 5 + 1 )
		self.storedCategories[ CatID ]:Dock( TOP )
		self.storedCategories[ CatID ].Paint = function( pnl, w, h )
				-- Perimeter of button
			DrawRoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, ANUS_MENUALPHA ) )

			local height = h - 1
			if not self.Categories.pnlCanvas:GetChildren()[ #self.Categories.pnlCanvas:GetChildren() ] == pnl and pnl.Pressed then
				height = h
			end

				-- interior of button
			DrawRoundedBox( 0, 0, 0, w - 1, height, pnl.Pressed and Color( 225, 225, 225, ANUS_MENUALPHA ) or Color( 255, 255, 255, ANUS_MENUALPHA ) )
		end
		self.storedCategories[ CatID ].DoClick = function( pnl )
			if not self.allowCategoryClicks then return end
			if self.openedCategory and self.openedCategory == pnl then return end
			
			if self.openedCategory then
				self.storedContent[ self.openedCategoryCatID ] = CreateAnonymousPanel()
				for k,v in ipairs( self.Content:GetChildren() ) do
					v:SetParent( self.storedContent[ self.openedCategoryCatID ] )
				end

				self.Content:Clear()
				self.openedCategory.Pressed = false
			end
			
			self.openedCategory = pnl
			self.openedCategoryCatID = CatID
			pnl.Pressed = true
			
			
			if self.storedContent[ CatID ] then
				for k,v in ipairs( self.storedContent[ CatID ]:GetChildren() or {} ) do
					v:SetParent( self.Content )
				end	
			else
				v:Initialize( self.Content )
			end
		end
	end
	
	if self.openedCategoryCatID then
		if self.storedCategories[ self.openedCategoryCatID ] then
			self.storedCategories[ self.openedCategoryCatID ].DoClick( self.storedCategories[ self.openedCategoryCatID ] )
			--self.Categories:ScrollToChild( self.openedCategory )
		else
			self.openedCategoryCatID = nil
		end
	end
end 

function Panel:Paint()
	BgColor.a = self.ChatBoxOpen and 80 or 255
	DrawRoundedBox( 4, 0, 0, ANUS_MENUWIDE, ANUS_MENUTALL, BgColor )
end

function Panel:GetActiveCategoryName()
	return self.openedCategoryCatID
end
 
vgui.Register( "anus_mainmenu", Panel, "EditablePanel" )