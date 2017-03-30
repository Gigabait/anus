--[[

	DListView
	
	Columned list view

	TheList = vgui.Create( "DListView" )
	
	local Col1 = TheList:AddColumn( "Address" )
	local Col2 = TheList:AddColumn( "Port" )
	
	Col2:SetMinWidth( 30 )
	Col2:SetMaxWidth( 30 )
	
	TheList:AddLine( "192.168.0.1", "80" )
	TheList:AddLine( "192.168.0.2", "80" )
	
	etc

--]]

local PANEL = {}

AccessorFunc( PANEL, "m_bDirty",		"Dirty", FORCE_BOOL )
AccessorFunc( PANEL, "m_bSortable",		"Sortable", FORCE_BOOL )

AccessorFunc( PANEL, "m_iHeaderHeight",	"HeaderHeight" )
AccessorFunc( PANEL, "m_iDataHeight",	"DataHeight" )

AccessorFunc( PANEL, "m_bMultiSelect",	"MultiSelect" )
AccessorFunc( PANEL, "m_bHideHeaders",	"HideHeaders" )

Derma_Hook( PANEL, "Paint", "Paint", "ListView" )


--[[---------------------------------------------------------
   Name: Init
-----------------------------------------------------------]]
function PANEL:Init()

	self:SetSortable( true )
	self:SetMouseInputEnabled( true )
	self:SetMultiSelect( true )
	self:SetHideHeaders( false )

	self:SetDrawBackground( true )
	self:SetHeaderHeight( 30 )
	self:SetDataHeight( 30 )

	self.Columns = {}

	self.Lines = {}
	self.Sorted = {}

	self.Icons = {}

	self:SetDirty( true )

	self.pnlCanvas = vgui.Create( "Panel", self )

	self.VBar = vgui.Create( "DVScrollBar", self )
	self.VBar:SetZPos( 20 )
	
	/*print( "test" )
	local size = 0
	timer.Simple( 0.02, function()
		PrintTable( self.Columns )
		for k,v in next, self.Columns do
			size = v:GetWide() + size
		end
	
		print( size, "actual size: ", self:GetWide() )
		print( "enabled: ", self.VBar.Enabled )
	
		--[[if self.VBar and not self.VBar.Enabled then
			self.Columns[ #self.Columns ]:SetWide( self.Columns[ #self.Columns ]:GetWide() + (self:GetWide() - size) )
		end]]
		
		--print( "wide", self.Columns[ 5 ]:GetWide() )
		--[[self.Columns[ 5 ]:SetWide( 100 )
		self.Columns[ 5 ]:SetWide( 113` )]]
		--self.Columns[ 5 ]:SetWide( self.Columns[ 5 ]:GetWide() - 2 )
	end )*/

end

--[[---------------------------------------------------------
   Name: DisableScrollbar
-----------------------------------------------------------]]
function PANEL:DisableScrollbar()

	if ( IsValid( self.VBar ) ) then
		self.VBar:Remove()
	end

	self.VBar = nil

end

--[[---------------------------------------------------------
   Name: GetLines
-----------------------------------------------------------]]
function PANEL:GetLines()
	return self.Lines
end

--[[---------------------------------------------------------
   Name: GetInnerTall
-----------------------------------------------------------]]
function PANEL:GetInnerTall()
	return self:GetCanvas():GetTall()
end

--[[---------------------------------------------------------
   Name: GetCanvas
-----------------------------------------------------------]]
function PANEL:GetCanvas()
	return self.pnlCanvas
end

--[[---------------------------------------------------------
   Name: AddColumn
-----------------------------------------------------------]]
function PANEL:AddColumn( strName, iPosition )

	local pColumn = nil

	if ( self.m_bSortable ) then
		pColumn = vgui.Create( "anus_listview_column", self )
	else
		pColumn = vgui.Create( "anus_listview_columnplain", self )
	end

	pColumn:SetName( strName )
	pColumn.Header:SetFont( "anus_SmallTitleBolded" )
	pColumn:SetZPos( 10 )

	if ( iPosition ) then
	
		table.insert( self.Columns, iPosition, pColumn )
		
		for i = 1,#self.Columns do
			self.Columns[ i ]:SetColumnID( i )
		end
	
	else
	
		local ID = table.insert( self.Columns, pColumn )
		pColumn:SetColumnID( ID )
	
	end

	self:InvalidateLayout()

	return pColumn

end

--[[---------------------------------------------------------
   Name: RemoveLine
-----------------------------------------------------------]]
function PANEL:RemoveLine( LineID )

	local Line = self:GetLine( LineID )
	local SelectedID = self:GetSortedID( LineID )

	self:ClearSelection()
	self.Lines[ LineID ] = nil
	table.remove( self.Sorted, SelectedID )

	self:SetDirty( true )
	self:InvalidateLayout()

	Line:Remove()

end

--[[---------------------------------------------------------
   Name: ColumnWidth
-----------------------------------------------------------]]
function PANEL:ColumnWidth( i )

	local ctrl = self.Columns[ i ]
	if ( !ctrl ) then return 0 end

	return ctrl:GetWide()

end

--[[---------------------------------------------------------
   Name: FixColumnsLayout
-----------------------------------------------------------]]
Remain = 0
function PANEL:FixColumnsLayout()

	local NumColumns = #self.Columns
	if ( NumColumns == 0 ) then return end

	local AllWidth = 0
	for k, Column in ipairs( self.Columns ) do
		AllWidth = AllWidth + Column:GetWide()
	end
	
	local ChangeRequired = self.pnlCanvas:GetWide() - AllWidth
	local ChangePerColumn = math.floor( ChangeRequired / NumColumns )
	local Remainder = ChangeRequired - (ChangePerColumn * NumColumns)
	
	for k, Column in ipairs( self.Columns ) do

		local TargetWidth = Column:GetWide() + ChangePerColumn
		Remainder = Remainder + ( TargetWidth - Column:SetWidth( TargetWidth ) )
	
	end
	
	--print( "testzzz" )
	local remain = {}
	-- If there's a remainder, try to palm it off on the other panels, equally
	while ( Remainder != 0 ) do
		
		local PerPanel = math.floor( Remainder / NumColumns ) + 1
		
		for k, Column in ipairs( self.Columns ) do
	
			Remainder = math.Approach( Remainder, 0, PerPanel )
			
			local TargetWidth = Column:GetWide() + PerPanel
			Remainder = Remainder + (TargetWidth - Column:SetWidth( TargetWidth ))
			
			if ( Remainder == 0 ) then break end
		
		end
		--print( "a",  Remainder )
		
		Remainder = math.Approach( Remainder, 0, 1 )
	
	end
	--print( "remaine " , Remainder )

	-- Set the positions of the resized columns
	local x = 0
	for k, Column in ipairs( self.Columns ) do
	
		Column.x = x
		x = x + Column:GetWide()
		
		Column:SetTall( self:GetHeaderHeight() )
		Column:SetVisible( !self:GetHideHeaders() )
	
	end

end

--[[---------------------------------------------------------
   Name: Paint
-----------------------------------------------------------]]
function PANEL:PerformLayout()

	-- Do Scrollbar
	local Wide = self:GetWide()
	local YPos = 0
	
	if ( IsValid( self.VBar ) ) then
	
		self.VBar:SetPos( self:GetWide() - 16, 0 )
		self.VBar:SetSize( 16, self:GetTall() )
		self.VBar:SetUp( self.VBar:GetTall() - self:GetHeaderHeight(), self.pnlCanvas:GetTall() )
		YPos = self.VBar:GetOffset()

		if ( self.VBar.Enabled ) then Wide = Wide - 16 end
	
	end

	if ( self.m_bHideHeaders ) then
		self.pnlCanvas:SetPos( 0, YPos )
	else
		self.pnlCanvas:SetPos( 0, YPos + self:GetHeaderHeight() )
	end

	self.pnlCanvas:SetSize( Wide, self.pnlCanvas:GetTall() )

	self:FixColumnsLayout()
	--[[timer.Simple( 0.1, function()
		print( "remain..\n" .. Remain )
		--PrintTable( self.Columns )
		self.Columns[ #self.Columns ]:SetWide( self.Columns[ #self.Columns ]:GetWide() + Remain )
	end )]]

	--
	-- If the data is dirty, re-layout
	--
	if ( self:GetDirty( true ) ) then
	
		self:SetDirty( false )
		local y = self:DataLayout()
		self.pnlCanvas:SetTall( y )
		
		-- Layout again, since stuff has changed..
		self:InvalidateLayout( true )
	
	end

end

--[[---------------------------------------------------------
   Name: OnScrollbarAppear
-----------------------------------------------------------]]
function PANEL:OnScrollbarAppear()

	self:SetDirty( true )
	self:InvalidateLayout()

end

--[[---------------------------------------------------------
   Name: OnRequestResize
-----------------------------------------------------------]]
function PANEL:OnRequestResize( SizingColumn, iSize )
	
	-- Find the column to the right of this one
	local Passed = false
	local RightColumn = nil
	for k, Column in ipairs( self.Columns ) do
	
		if ( Passed ) then
			RightColumn = Column
			break
		end
	
		if ( SizingColumn == Column ) then Passed = true end
	
	end
	
	-- Alter the size of the column on the right too, slightly
	if ( RightColumn ) then
	
		local SizeChange = SizingColumn:GetWide() - iSize
		RightColumn:SetWide( RightColumn:GetWide() + SizeChange )
		
	end
	
	SizingColumn:SetWide( iSize )
	self:SetDirty( true )
	
	-- Invalidating will munge all the columns about and make it right
	self:InvalidateLayout()

end

--[[---------------------------------------------------------
   Name: DataLayout
-----------------------------------------------------------]]
function PANEL:DataLayout()

	local y = 0
	local h = self.m_iDataHeight
	
	for k, Line in ipairs( self.Sorted ) do
	
		Line:SetPos( 1, y )
		Line:SetSize( self:GetWide()-2, h )
		Line:DataLayout( self ) 
		
		Line:SetAltLine( k % 2 == 1 )
		
		y = y + Line:GetTall()
	
	end
	
	return y

end

--[[---------------------------------------------------------
   Name: AddLine - returns the line number.
-----------------------------------------------------------]]
function PANEL:AddLine( ... )

	self:SetDirty( true )
	self:InvalidateLayout()

	local Line = vgui.Create( "anus_listview_line", self.pnlCanvas )
	local ID = #self.Lines + 1
	self.Lines[ ID ] = Line
	
	Line:SetListView( self ) 
	Line:SetID( ID )

	-- This assures that there will be an entry for every column
	for k, v in ipairs( self.Columns ) do
		Line:SetColumnText( k, "" )
	end

	for k, v in ipairs( {...} ) do
		Line:SetColumnText( k, v )
	end

	-- Make appear at the bottom of the sorted list
	local SortID = table.insert( self.Sorted, Line )
	
	if ( SortID % 2 == 1 ) then
		Line:SetAltLine( true )
	end

	return Line

end

--[[---------------------------------------------------------
   Name: OnMouseWheeled
-----------------------------------------------------------]]
function PANEL:OnMouseWheeled( dlta )

	if ( !IsValid( self.VBar ) ) then return end
	
	return self.VBar:OnMouseWheeled( dlta )

end

--[[---------------------------------------------------------
   Name: OnMouseWheeled
-----------------------------------------------------------]]
function PANEL:ClearSelection( dlta )

	for k, Line in ipairs( self.Lines ) do
		Line:SetSelected( false )
	end

end

--[[---------------------------------------------------------
   Name: GetSelectedLine
-----------------------------------------------------------]]
function PANEL:GetSelectedLine()

	for k, Line in ipairs( self.Lines ) do
		if ( Line:IsSelected() ) then return k end
	end

end

--[[---------------------------------------------------------
   Name: GetLine
-----------------------------------------------------------]]
function PANEL:GetLine( id )

	return self.Lines[ id ]

end

--[[---------------------------------------------------------
   Name: GetSortedID
-----------------------------------------------------------]]
function PANEL:GetSortedID( line )

	for k, v in pairs( self.Sorted ) do
	
		if ( v:GetID() == line ) then return k end
	
	end

end

--[[---------------------------------------------------------
   Name: OnClickLine
-----------------------------------------------------------]]
function PANEL:OnClickLine( Line, bClear )

	local bMultiSelect = self.m_bMultiSelect
	if ( !bMultiSelect && !bClear ) then return end

	--
	-- Control, multi select
	--
	if ( bMultiSelect && input.IsKeyDown( KEY_LCONTROL ) ) then
		bClear = false
	end

	--
	-- Shift block select
	--
	if ( bMultiSelect && input.IsKeyDown( KEY_LSHIFT ) ) then
	
		local Selected = self:GetSortedID( self:GetSelectedLine() )
		if ( Selected ) then
		
			if ( bClear ) then self:ClearSelection() end
			
			local LineID = self:GetSortedID( Line:GetID() )
		
			local First = math.min( Selected, LineID )
			local Last = math.max( Selected, LineID )
			
			for id = First, Last do
			
				local line = self.Sorted[ id ]
				line:SetSelected( true )
			
			end
		
			return
		
		end
		
	end

	--
	-- Check for double click
	--
	if ( Line:IsSelected() && Line.m_fClickTime && (!bMultiSelect || bClear) ) then 
	
		local fTimeDistance = SysTime() - Line.m_fClickTime

		if ( fTimeDistance < 0.3 ) then
			self:DoDoubleClick( Line:GetID(), Line )
			return
		end
	
	end

	--
	-- If it's a new mouse click, or this isn't 
	--  multiselect we clear the selection
	--
	if ( !bMultiSelect || bClear ) then
		self:ClearSelection()
	end

	if ( Line:IsSelected() ) then return end

	Line:SetSelected( true )
	Line.m_fClickTime = SysTime()
	
	self:OnRowSelected( Line:GetID(), Line )

end

function PANEL:SortByColumns( c1, d1, c2, d2, c3, d3, c4, d4 )

	table.Copy( self.Sorted, self.Lines )
	
	table.sort( self.Sorted, function( a, b ) 

			if (!IsValid( a )) then return true end
			if (!IsValid( b )) then return false end
			
			if ( c1 && a:GetColumnText( c1 ) != b:GetColumnText( c1 ) ) then
				if ( d1 ) then a, b = b, a end
				return a:GetColumnText( c1 ) < b:GetColumnText( c1 )
			end
			
			if ( c2 && a:GetColumnText( c2 ) != b:GetColumnText( c2 ) ) then
				if ( d2 ) then a, b = b, a end
				return a:GetColumnText( c2 ) < b:GetColumnText( c2 )
			end
				
			if ( c3 && a:GetColumnText( c3 ) != b:GetColumnText( c3 ) ) then
				if ( d3 ) then a, b = b, a end
				return a:GetColumnText( c3 ) < b:GetColumnText( c3 )
			end
			
			if ( c4 && a:GetColumnText( c4 ) != b:GetColumnText( c4 ) ) then
				if ( d4 ) then a, b = b, a end
				return a:GetColumnText( c4 ) < b:GetColumnText( c4 )
			end
			
			return true
	end )

	self:SetDirty( true )
	self:InvalidateLayout()

end

--[[---------------------------------------------------------
   Name: SortByColumn
-----------------------------------------------------------]]
function PANEL:SortByColumn( ColumnID, Desc )
	
	table.Copy( self.Sorted, self.Lines )

	table.sort( self.Sorted, function( a, b ) 

		if ( Desc ) then
			a, b = b, a
		end
		
		local aval = a:GetSortValue( ColumnID ) and a:GetSortValue( ColumnID ) or a:GetColumnText( ColumnID )
		local bval = b:GetSortValue( ColumnID ) and b:GetSortValue( ColumnID ) or b:GetColumnText( ColumnID )

		return aval < bval

	end )

	self:SetDirty( true )
	self:InvalidateLayout()
	
	for k,v in pairs( self.Columns ) do
		if ColumnID == k then continue end
		
		if v.btnScending and IsValid( v.btnScending ) then
			v.btnScending:Remove()
			v.btnScending = nil
		end
	end

end

--[[---------------------------------------------------------
   Name: SelectFirstItem
   Selects the first item based on sort..
-----------------------------------------------------------]]
function PANEL:SelectItem( Item )

	if ( !Item ) then return end

	Item:SetSelected( true )
	self:OnRowSelected( Item:GetID(), Item )

end

--[[---------------------------------------------------------
   Name: SelectFirstItem
   Selects the first item based on sort..
-----------------------------------------------------------]]
function PANEL:SelectFirstItem()

	self:ClearSelection()
	self:SelectItem( self.Sorted[ 1 ] )

end

--[[---------------------------------------------------------
   Name: DoDoubleClick
-----------------------------------------------------------]]
function PANEL:DoDoubleClick( LineID, Line )

	-- For Override

end

--[[---------------------------------------------------------
   Name: OnRowSelected
-----------------------------------------------------------]]
function PANEL:OnRowSelected( LineID, Line )

	-- For Override

end

--[[---------------------------------------------------------
   Name: OnRowRightClick
-----------------------------------------------------------]]
function PANEL:OnRowRightClick( LineID, Line )

	-- For Override

end

function PANEL:OnRowLeftClick( LineID, Line )

	-- For Override
	
end

--[[---------------------------------------------------------
   Name: Clear
-----------------------------------------------------------]]
function PANEL:Clear()

	for k, v in pairs( self.Lines ) do
		v:Remove()
	end

	self.Lines = {}
	self.Sorted = {}

	self:SetDirty( true )

end

--[[---------------------------------------------------------
   Name: GetSelected
-----------------------------------------------------------]]
function PANEL:GetSelected()

	local ret = {}

	for k, v in ipairs( self.Lines ) do
		if ( v:IsLineSelected() ) then
			table.insert( ret, v )
		end
	end

	return ret

end

--[[---------------------------------------------------------
   Name: SizeToContents
-----------------------------------------------------------]]
function PANEL:SizeToContents( )

	self:SetHeight( self.pnlCanvas:GetTall() + self:GetHeaderHeight() )

end

local drawRoundedBox = draw.RoundedBox
function PANEL:Paint( w, h )
		-- left
	drawRoundedBox( 0, 0, 0, 1, h, Color( 120, 120, 120, ANUS_MENUALPHA ) )
	--DisableClipping( true )
			-- bottom
		drawRoundedBox( 0, 0, h - 1, w, 1, Color( 120, 120, 120, ANUS_MENUALPHA ) )
				-- right
		drawRoundedBox( 0, w - 1, 0, 1, h, Color( 120, 120, 120, ANUS_MENUALPHA ) )
	---DisableClipping( false )
end

--[[---------------------------------------------------------
   Name: GenerateExample
-----------------------------------------------------------]]
function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )

	local ctrl = vgui.Create( ClassName )
		
		local Col1 = ctrl:AddColumn( "Address" )
		local Col2 = ctrl:AddColumn( "Port" )
	
		Col2:SetMinWidth( 30 )
		Col2:SetMaxWidth( 30 )
	
		for i=1, 128 do
			ctrl:AddLine( "192.168.0."..i, "80" )
		end
		
		ctrl:SetSize( 300, 200 )
		
	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )

end

derma.DefineControl( "anus_listview", "Data View", PANEL, "DPanel" )
