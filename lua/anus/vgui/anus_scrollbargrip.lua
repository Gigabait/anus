--[[   _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

	DScrollBarGrip

--]]

local PANEL = {}

--[[---------------------------------------------------------
   Name: Init
-----------------------------------------------------------]]
function PANEL:Init()
end

--[[---------------------------------------------------------
   Name: OnMousePressed
-----------------------------------------------------------]]
function PANEL:OnMousePressed()

	self:GetParent():Grip( 1 )

end

--[[---------------------------------------------------------
   Name: Paint
-----------------------------------------------------------]]
function PANEL:Paint( w, h )
	
	--derma.SkinHook( "Paint", "ScrollBarGrip", self, w, h )
	--draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, 255 ) )
	return true
	
end

derma.DefineControl( "anus_scrollbargrip", "A Scrollbar Grip", PANEL, "DPanel" )