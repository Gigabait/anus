
local PANEL = {}

--[[---------------------------------------------------------
	Name: Init
-----------------------------------------------------------]]
function PANEL:Init()

	self:SetTextInset( 5, 0 )

end

function PANEL:UpdateColours( skin )

	if self.IconImage then return self:SetTextStyleColor( Color( 0, 0, 0, 0 ) ) end

	if ( self:GetParent():IsLineSelected() ) then return self:SetTextStyleColor( skin.Colours.Label.Bright ) end

	return self:SetTextStyleColor( skin.Colours.Label.Dark )

end

function PANEL:Think()
	if not self:GetParent().Icons[ self.ColumnID ] then return end
	
	if not self.IconImage then
		self.IconImage = vgui.Create( "DImage", self )
		if not Material( self:GetText() ) then
			self:SetText( "icon16/help.png" )
		end
		self.IconImage:SetImage( self:GetText(), "materials/icon16/help.png" )
		self.IconImage:SetSize( 16, 16 )
		self.IconImage:SetPos( 2, self.IconImage:GetTall() / 2 )
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
		
	end

	self:GetListView():OnClickLine( self, true )
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
	
	if self.altLine then
		draw.RoundedBox( 0, 0, 0, w, h, Color( 240, 240, 240, 255 ) )
	end

end

function PANEL:SetAltLine( bdark )
	
	self.altLine = bdark

end

function PANEL:SetLineIcon( ColumnID, path )
	self.Icons[ ColumnID ] = true
end
	
derma.DefineControl( "anus_listviewline", "A line from the List View", PANEL, "Panel" )
derma.DefineControl( "anus_listview_line", "A line from the List View", PANEL, "Panel" )
