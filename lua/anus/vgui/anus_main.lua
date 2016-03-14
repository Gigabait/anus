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
	weight = 900,
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

local psizew,psizeh = 960, 640
local bgColor = Color( 218, 218, 218, 255 )

function panel:Init()
	self:SetSize( psizew, psizeh )
	self:Center()
	self:SetKeyBoardInputEnabled( true )
	gui.EnableScreenClicker( true )
	
	self.Categories = self:Add( "DScrollPanel" )
	self.Categories:SetSize( self:GetSize() / 7, self:GetTall() )
	--self.Categories:SetPos( 0, 0 )
	self.Categories:Dock( LEFT )
	self.Categories.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h - self.resizeNum or 0, color_white )
	end
	
	self.CategoryList = {}
	self.CategoryLastClicked = nil
	
	for k,v in next, anus.MenuCategories do
		self.CategoryList.k = self.Categories:Add( "DButton" )
		self.CategoryList.k:SetText( k or "Unknown" )
		self.CategoryList.k:SetFont( "anus_SmallTitle" )
		self.CategoryList.k:SetSize( self.Categories:GetWide(), self.Categories:GetWide() )
		--self.CategoryList.k:SetPos( 0, math.random( 1, 150 ) )
		self.CategoryList.k:Dock( TOP )
		self.CategoryList.k.Paint = function( pnl, w, h )
				-- Perimeter of button
			draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, 255 ) )
				-- interior of button
			draw.RoundedBox( 0, 0, 0, w - 1, h - 1, color_white )
		end
		self.CategoryList.k.DoClick = function( pnl )
			if self.CategoryLastClicked then
				self.Content:Remove()
			end
			self.CategoryLastClicked = pnl
		
			local categoryposx, categoryposy = self.Categories:GetPos()
		
			--[[self.Content = self:Add( "anus_menucontent" )
			self.Content:SetSize( (self:GetWide() - self.Categories:GetWide()) - 40, self:GetTall() - 40 )
			self.Content:SetPos( self.Categories:GetWide() + 20, 20 )]]
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
	
	--self.Categories:SetTall( resizeNum )
end

function panel:Paint()
	draw.RoundedBox( 4, 0, 0, psizew, psizeh, bgColor )
end

vgui.Register( "anus_mainmenu", panel )