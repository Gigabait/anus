
local PANEL = {}

--[[---------------------------------------------------------
	Name: Init
-----------------------------------------------------------]]
function PANEL:Init()

	self:SetTextInset( 5, 0 )

end

function PANEL:UpdateColours( skin )

	if self.IconImage then return self:SetTextStyleColor( Color( 0, 0, 0, 0 ) ) end
	
--	if ( self:GetParent():IsLineSelected() ) then print( "mo" )return self:SetTextStyleColor( skin.Colours.Label.Bright ) end

	if self:GetParent().Colors and self:GetParent().Colors[ self.ColumnID ] then
		return self:SetTextStyleColor( self:GetParent().Colors[ self.ColumnID ] )
	end

	return self:SetTextStyleColor( Color( 10, 10, 10, 255 ) )--skin.Colours.Label.Dark )

end

function PANEL:Think()
	if self:GetParent().Icons[ self.ColumnID ] and not self.IconImage or ( self.TextSet and self:GetText() != self.TextSet) then
		self.IconImage = self.IconImage or vgui.Create( "DImage", self )
		if not Material( self:GetText() ) then
			self:SetText( "icon16/help.png" )
		end
		self.IconImage:SetImage( self:GetText(), "materials/icon16/help.png" )
		self.IconImage:SetSize( 16, 16 )
		self.IconImage:SetPos( 2, self.IconImage:GetTall() / 2 )
		self.IconImage.DoClick = function()
			print( "test" )
		end
		
		self.TextSet = self:GetText()
	end
end
	

function PANEL:GenerateExample()

	// Do nothing!

end

derma.DefineControl( "anus_listviewlabel", "", PANEL, "DLabel" )

local PANEL = {}

Derma_Hook( PANEL, "Paint", "Paint", "ListViewLine" )
Derma_Hook( PANEL, "ApplySchemeSettings", "Scheme", "ListViewLine" )
Derma_Hook( PANEL, "PerformLayout", "Layout", "ListViewLine" )

AccessorFunc( PANEL, "m_iID", "ID" )
AccessorFunc( PANEL, "m_pListView", "ListView" )
AccessorFunc( PANEL, "m_bAlt", "AltLine" )

--[[---------------------------------------------------------
	Name: Init
-----------------------------------------------------------]]
function PANEL:Init()

	self:SetSelectable( true )
	self:SetMouseInputEnabled( true )

	self.Columns = {}
	self.Data = {}
	
	self.Icons = {}
	self.Colors = {}

end

--[[---------------------------------------------------------
	Name: OnSelect
-----------------------------------------------------------]]
function PANEL:OnSelect()

	-- For override

end

--[[---------------------------------------------------------
	Name: OnRightClick
-----------------------------------------------------------]]
function PANEL:OnRightClick()

	-- For override

end

--[[---------------------------------------------------------
   Name: OnMousePressed
-----------------------------------------------------------]]
function PANEL:OnMousePressed( mcode )


	if ( mcode == MOUSE_RIGHT ) then
	
		-- This is probably the expected behaviour..
		if ( !self:IsLineSelected() ) then
		
			self:GetListView():OnClickLine( self, true )
			self:OnSelect()

		end
		
		self:GetListView():OnRowRightClick( self:GetID(), self )
		self:OnRightClick()
		
		return
		
	elseif mcode == MOUSE_LEFT then
		
			-- This is probably the expected behaviour..
		--if ( !self:IsLineSelected() ) then
		
			self:GetListView():OnClickLine( self, true )
			self:OnSelect()

		--end
		
		self:GetListView():OnRowLeftClick( self:GetID(), self )
		--self:OnLeftClick()
		
		return
	end

	self:GetListView():OnClickLine( self, true, mcode == MOUSE_RIGHT )
	self:OnSelect()

end

--[[---------------------------------------------------------
	Name: OnMousePressed
-----------------------------------------------------------]]
function PANEL:OnCursorMoved()

	if ( input.IsMouseDown( MOUSE_LEFT ) ) then
		self:GetListView():OnClickLine( self )
	end

end

--[[---------------------------------------------------------
	Name: IsLineSelected
-----------------------------------------------------------]]
function PANEL:SetSelected( b )

	self.m_bSelected = b

end

function PANEL:IsLineSelected()

	return self.m_bSelected

end

--[[---------------------------------------------------------
	Name: SetColumnText
-----------------------------------------------------------]]
function PANEL:SetColumnText( i, strText )

	if ( type( strText ) == "Panel" ) then
	
		if ( IsValid( self.Columns[ i ] ) ) then self.Columns[ i ]:Remove() end
	
		strText:SetParent( self )
		self.Columns[ i ] = strText
		self.Columns[ i ].Value = strText
		return
	
	end

	if ( !IsValid( self.Columns[ i ] ) ) then
	
		self.Columns[ i ] = vgui.Create( "anus_listviewlabel", self )
		self.Columns[ i ]:SetMouseInputEnabled( false )
	
	end
	
	self.Columns[ i ]:SetText( tostring( strText ) )
	self.Columns[ i ].Value = strText
	self.Columns[ i ].ColumnID = i
	return self.Columns[ i ]

end
PANEL.SetValue = PANEL.SetColumnText

--[[---------------------------------------------------------
	Name: GetColumnText
-----------------------------------------------------------]]
function PANEL:GetColumnText( i )

	if ( !self.Columns[ i ] ) then return "" end

	return self.Columns[ i ].Value

end

PANEL.GetValue = PANEL.GetColumnText

--[[---------------------------------------------------------
	Name: SetSortValue

	Allows you to store data per column

	Used in the SortByColumn function for incase you want to
	sort with something else than the text
-----------------------------------------------------------]]
function PANEL:SetSortValue( i, data )

	self.Data[ i ] = data

end

--[[---------------------------------------------------------
	Name: GetSortValue
-----------------------------------------------------------]]
function PANEL:GetSortValue( i )

	return self.Data[ i ]

end

--[[---------------------------------------------------------
	Name: SetColumnText
-----------------------------------------------------------]]
function PANEL:DataLayout( ListView )

	self:ApplySchemeSettings()

	local height = self:GetTall()

	local x = 0
	for k, Column in pairs( self.Columns ) do
	
		local w = ListView:ColumnWidth( k )
		Column:SetPos( x, 0 )
		Column:SetSize( w, height )
		x = x + w

	end

end

function PANEL:Paint( w, h )

	if self.customPaint then
		draw.RoundedBox( 0, 0, 0, w, h, self.customPaint )
		return
	end
	
	if self:IsLineSelected() then
		draw.RoundedBox( 0, 0, 0, w, h, Color( 225, 225, 225, 255 ) )
		return
	end
	
	if self.altLine then
		draw.RoundedBox( 0, 0, 0, w, h, Color( 240, 240, 240, 255 ) )
	end

end

function PANEL:SetAltLine( bdark )
	
	self.altLine = bdark

end

function PANEL:SetLineIcon( ColumnID, path )
	self.Icons[ ColumnID ] = "icon"
	self.TextSet = self:GetText()
end

function PANEL:SetLineIconButton( ColumnID, callback )
	self.Icons[ ColumnID ] = "button"
	self.LineClick = "button"
	self.LineClickFunction = callback
	self.TextSet = self:GetText()
end

function PANEL:SetLineColor( ColumnID, color )
	self.Colors[ ColumnID ] = color
end
	
derma.DefineControl( "anus_listviewline", "A line from the List View", PANEL, "Panel" )
derma.DefineControl( "anus_listview_line", "A line from the List View", PANEL, "Panel" )
