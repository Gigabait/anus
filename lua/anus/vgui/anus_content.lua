local panel = {}

function panel:Init()
	--self:SetSize( 
	--self:DockMargin( 60, 20, 20, 20 )
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
	draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, 255 ) ) 
	draw.RoundedBox( 0, 1, 1, w - 2, h - 2, color_white )
end

function panel:Think()
	for k,v in next, self:GetChildren() do
		v:DockMargin( 20, 80, 20, 20 )
	end
end

vgui.Register( "anus_contentpanel", panel )