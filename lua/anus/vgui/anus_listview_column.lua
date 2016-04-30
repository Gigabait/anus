--[[   _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

	DListView
	
	Columned list view

--]]

local PANEL = {}

Derma_Hook( PANEL, 	"Paint", "Paint", "ListViewHeaderLabel" )
Derma_Hook( PANEL, 	"ApplySchemeSettings", "Scheme", "ListViewHeaderLabel" )
Derma_Hook( PANEL, 	"PerformLayout", "Layout", "ListViewHeaderLabel" )

--[[---------------------------------------------------------
   Name: Init
-----------------------------------------------------------]]
function PANEL:Init()
end

-- No example for this control. Why do we have this control?
function PANEL:GenerateExample( class, tabs, w, h )
end

derma.DefineControl( "anus_listviewheaderlabel", "", PANEL, "DLabel" )

local PANEL = {}

--[[---------------------------------------------------------
   Name: Init
-----------------------------------------------------------]]
function PANEL:Init()

	self:SetCursor( "sizewe" )

end

--[[---------------------------------------------------------
   Name: Paint
-----------------------------------------------------------]]
function PANEL:Paint()

	return true

end

--[[---------------------------------------------------------
   Name: OnCursorMoved
-----------------------------------------------------------]]
function PANEL:OnCursorMoved()

	if ( self.Depressed ) then
	
		local x, y = self:GetParent():CursorPos()
	
		self:GetParent():ResizeColumn( x )
	end

end

-- No example for this control
function PANEL:GenerateExample( class, tabs, w, h )
end

derma.DefineControl( "anus_listview_draggerbar", "", PANEL, "DButton" )

local PANEL = {}

AccessorFunc( PANEL, "m_iMinWidth", 			"MinWidth" )
AccessorFunc( PANEL, "m_iMaxWidth", 			"MaxWidth" )

AccessorFunc( PANEL, "m_iTextAlign", 			"TextAlign" )

AccessorFunc( PANEL, "m_bFixedWidth", 			"FixedWidth" )
AccessorFunc( PANEL, "m_bDesc", 				"Descending" )
AccessorFunc( PANEL, "m_iColumnID", 			"ColumnID" )

Derma_Hook( PANEL, 	"Paint", "Paint", "ListViewColumn" )
Derma_Hook( PANEL, 	"ApplySchemeSettings", "Scheme", "ListViewColumn" )
Derma_Hook( PANEL, 	"PerformLayout", "Layout", "ListViewColumn" )

--[[---------------------------------------------------------
   Name: Init
-----------------------------------------------------------]]
function PANEL:Init()

	self.Header = vgui.Create( "anus_button", self )
	self.Header.DoClick = function() self:DoClick() end
	self.Header.DoRightClick = function() self:DoRightClick() end
	--[[self.Header.Paint = function( self, w, h )
			-- top
		draw.RoundedBox( 0, 0, 0, w, 1, Color( 120, 120, 120, 255 ) )
			-- left
		draw.RoundedBox( 0, 0, 0, 1, h, Color( 120, 120, 120, 255 ) )
		DisableClipping( true )
				-- bottom
			draw.RoundedBox( 0, 0, h, w, 1, Color( 120, 120, 120, 255 ) )
				-- right
			draw.RoundedBox( 0, w - 1, 0, 1, h, Color( 120, 120, 120, 255 ) )
		DisableClipping( false )
	end]]
	
	self.DraggerBar = vgui.Create( "anus_listview_draggerbar", self )
	
	self:SetMinWidth( 10 )
	self:SetMaxWidth( 1920 * 10 )

end

--[[---------------------------------------------------------
   Name: SetFixedWidth
-----------------------------------------------------------]]
function PANEL:SetFixedWidth( i )

	self:SetMinWidth( i )
	self:SetMaxWidth( i )

end

--[[---------------------------------------------------------
   Name: DoClick
-----------------------------------------------------------]]
function PANEL:DoClick()

	self:GetParent():SortByColumn( self:GetColumnID(), self:GetDescending() )
	self:SetDescending( !self:GetDescending() )
	
	if not self:GetDescending() then
		if self.btnScending then
			self.btnScending:Remove()
		end
		self.btnScending = vgui.Create( "DButton", self )
		self.btnScending:SetText( "" )
		self.btnScending.Paint = function( panel, w, h )
			--derma.SkinHook( "Paint", "ButtonUp", panel, w, h ) 
			--derma.SkinHook( "Paint", "NumberUp", panel, w, h )
			
			--"SKIN.tex.Input.UpDown.Up.Normal		= GWEN.CreateTextureCentered( 384,		112, 7, 7 )
			
			
			local NumberUp_UpDown_Up_Normal = GWEN.CreateTextureCentered( 384,		112, 7, 7 )
			return NumberUp_UpDown_Up_Normal( 0, 0, w, h )
		end
	else
		if self.btnScending then
			self.btnScending:Remove()
		end
		self.btnScending = vgui.Create( "DButton", self )
		self.btnScending:SetText( "" )
		self.btnScending.Paint = function( panel, w, h )
			--derma.SkinHook( "Paint", "ButtonUp", panel, w, h ) 
			derma.SkinHook( "Paint", "NumberDown", panel, w, h )
		end
		--GWEN.CreateTextureCentered( 384,		120, 7, 7 )
	end
		
end

--[[---------------------------------------------------------
   Name: DoRightClick
-----------------------------------------------------------]]
function PANEL:DoRightClick()

end

--[[---------------------------------------------------------
   Name: SetName
-----------------------------------------------------------]]
function PANEL:SetName( strName )

	self.Header:SetText( strName:upper() )

end

--[[---------------------------------------------------------
   Name: Paint
-----------------------------------------------------------]]
function PANEL:Paint()
	return true
end

--[[---------------------------------------------------------
   Name: PerformLayout
-----------------------------------------------------------]]
function PANEL:PerformLayout()

	if ( self.m_iTextAlign ) then 
		self.Header:SetContentAlignment( self.m_iTextAlign ) 
	end
		
	self.Header:SetPos( 0, 0 )
	self.Header:SetSize( self:GetWide() , self:GetParent():GetHeaderHeight() )
	
	self.DraggerBar:SetWide( 4 )
	self.DraggerBar:StretchToParent( nil, 0, nil, 0 )
	self.DraggerBar:AlignRight()
	
	if self.btnScending then
		surface.SetFont( self.Header:GetFont() )
		local headertextw, headertexth = surface.GetTextSize( self.Header:GetText() )
		local headertextx, headertexty = (self.Header:GetWide() / 2 - headertextw / 2) + headertextw, self.Header:GetTall() / 2 - headertexth / 2
		
		
		if self.m_iTextAlign then
			self.btnScending:SetContentAlignment( self.m_iTextAlign )
		end
		
		self.btnScending:SetPos( headertextx + 5, headertexty )
		self.btnScending:SetSize( 5, 10 )
	end

end

--[[---------------------------------------------------------
   Name: ResizeColumn
-----------------------------------------------------------]]
function PANEL:ResizeColumn( iSize )

	self:GetParent():OnRequestResize( self, iSize )

end

--[[---------------------------------------------------------
   Name: SetWidth
-----------------------------------------------------------]]
function PANEL:SetWidth( iSize )

	iSize = math.Clamp( iSize, self.m_iMinWidth, self.m_iMaxWidth )
	
	-- If the column changes size we need to lay the data out too
	if ( iSize != self:GetWide() ) then
		self:GetParent():SetDirty( true )
	end

	self:SetWide( iSize )
	return iSize

end



derma.DefineControl( "anus_listview_column", "", table.Copy( PANEL ), "Panel" )

--[[---------------------------------------------------------
   Name: Init
-----------------------------------------------------------]]
function PANEL:Init()

	self.Header = vgui.Create( "anus_listviewheaderlabel", self )
	
	self.DraggerBar = vgui.Create( "anus_listview_draggerbar", self )
	
	self:SetMinWidth( 10 )
	self:SetMaxWidth( 1920 * 10 )

end

derma.DefineControl( "anus_listview_columnplain", "", PANEL, "Panel" )
