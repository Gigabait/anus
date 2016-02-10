local PANEL = {}

function PANEL:Init()
	self:SetSize( 250, 400 )
	self:Center()
end

function PANEL:Paint()
	draw.RoundedBox( 6, 0, 0, 600, 450 - 31, Color( 255, 255, 255, 255 ))
	draw.RoundedBox( 0, 5, 5, 600 - 10 , 450 - 42, Color( 241, 235, 209, 255 ) ) --Color( 230, 220, 207, 220 ) )
end

vgui.Register( "anus_mainmenu_new", PANEL )