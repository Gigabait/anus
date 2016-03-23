local panel = {}

surface.CreateFont( "anus_SmallTitle",
{
	font = "Verdana",
	size = 21,
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

local psizew,psizeh = 960, 640
local bgColor = Color( 231, 230, 237, 255 )

function panel:Init()
	self:SetSize( psizew, psizeh )
	self:Center()
	self:SetKeyBoardInputEnabled( true )
	gui.EnableScreenClicker( true )
	
	self.Categories = self:Add( "anus_scrollpanel" )
	self.Categories:SetSize( self:GetSize() / 7, self:GetTall() )
	self.Categories:Dock( LEFT )
	self.Categories.Paint = function( pnl, w, h )
		local new_h = h
		if self.resizeNum and self.resizeNum > new_h then
			new_h = h - self.resizeNum
		elseif self.resizeNum then
			new_h = self.resizeNum
		end
		draw.RoundedBox( 0, 0, 0, w, new_h, color_white )
	end
	
	self.CategoryList = {}
	self.CategoryLastClicked = nil
	
	for k,v in next, anus.MenuCategories do
		if v.pluginid and not LocalPlayer():HasAccess( v.pluginid ) then continue end
		
		self.CategoryList.k = self.Categories:Add( "DButton" )
		self.CategoryList.k:SetText( k or "Unknown" )
		self.CategoryList.k:SetFont( "anus_SmallTitle" )
		self.CategoryList.k:SetSize( self.Categories:GetWide(), self.Categories:GetWide() - 9 )
		self.CategoryList.k:Dock( TOP )
		self.CategoryList.k.Paint = function( pnl, w, h )
				-- Perimeter of button
			draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, 255 ) )
			
			local height = h - 1
			if self.Categories.pnlCanvas:GetChildren()[ #self.Categories.pnlCanvas:GetChildren() ] == pnl and pnl.Pressed then
				height = h
			end
			
				-- interior of button
			draw.RoundedBox( 0, 0, 0, w - 1, height, pnl.Pressed and Color( 225, 225, 225, 255 ) or color_white )
		end
		self.CategoryList.k.DoClick = function( pnl )
			if self.CategoryLastClicked then
				self.Content:Remove()
				self.CategoryLastClicked.Pressed = false
			end
			self.CategoryLastClicked = pnl
			pnl.Pressed = true
		
			local categoryposx, categoryposy = self.Categories:GetPos()

			self.Content = self:Add( "DPanel" )
			self.Content:SetSize( (self:GetWide() - self.Categories:GetWide()) - 40, self:GetTall() - 40 )
			self.Content:SetPos( self.Categories:GetWide() + 20, 20 )
			self.Content.Paint = function()
			end
			
			v:Initialize( self.Content )
			
		end
		self.Categories:AddItem( self.CategoryList.k )
	end
	
	self.resizeNum = 0
	for k,v in next, self.Categories.pnlCanvas:GetChildren() do
		self.resizeNum = self.resizeNum + v:GetTall()
	end
end

function panel:Paint()
	draw.RoundedBox( 4, 0, 0, psizew, psizeh, bgColor )
end

vgui.Register( "anus_mainmenu", panel )