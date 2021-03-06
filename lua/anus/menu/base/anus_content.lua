local panel = {}

surface.CreateFont( "anus_SmallText",
{
	font = "Verdana",
	weight = 640,
	size = 16,
} )

surface.CreateFont( "anus_TinyText",
{
	font = "Verdana",
	weight = 400,
	size = 14,
} )

function panel:Init()
	self:DockPadding( 0, 20, 0, 20 )
end

function panel:SetTitle( strTitle )
	self.strTitle = strTitle

	self.Title = self:Add( "DLabel" )
	self.Title:SetText( strTitle )
	self.Title:SetTextColor( Color( 140, 140, 140, 255 ) )
	self.Title:SetFont( "anus_MediumTitle" )
	self.Title:SetPos( 20, 20 )
	self.Title:SizeToContents()
end

function panel:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, ANUS_MENUALPHA ) )
	draw.RoundedBox( 0, 1, 1, w - 2, h - 2, Color( 255, 255, 255, ANUS_MENUALPHA ) )
end

function panel:Think()
	for k,v in next, self:GetChildren() do
		v:DockMargin( 20, 40, 20, -10 )
	end
end

vgui.Register( "anus_contentpanel", panel, "Panel" )