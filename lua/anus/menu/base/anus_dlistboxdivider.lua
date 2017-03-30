local PANEL = {}

AccessorFunc( PANEL, "m_pMother", "Mother" )
AccessorFunc( PANEL, "m_bSelected", "Selected" )
AccessorFunc( PANEL, "m_fClickTime", "ClickTime" )

function PANEL:Init()
	self:SetMouseInputEnabled( true )
	self:SetTextInset( 5, 0 )
	self:SetTall( 19 )
	self:SetDark( true )
end

function PANEL:OnMousePressed( mcode )
	if ( mcode == MOUSE_LEFT ) then
		self:Select( /*true*/ )
	end

	self:SetTextColor( Color( 0, 0, 0, 255 ) )
end

function PANEL:Paint( w, h )
	if ( self.m_pMother:GetSelectedValues() == self:GetText() ) or self:GetSelected() then
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 128, 255, 200 ) )
	elseif ( self.Hovered ) then
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 128, 255, 128 ) )
	end
end

function PANEL:OnCursorMoved( x, y )
	if ( input.IsMouseDown( MOUSE_LEFT ) ) then
		self:Select( false )
	end
end

function PANEL:Select( bOnlyMe )
	self.m_pMother:SelectItem( self, bOnlyMe )

	self:DoClick()
end

function PANEL:DoClick()
	-- For override
end

function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )
end

derma.DefineControl( "DListBoxDividerItem", "", PANEL, "DLabel" )

	-- eventually add support for more than 2 sides?

local PANEL = {}

AccessorFunc( PANEL, "m_bSelectMultiple", "MultiSelect", FORCE_BOOL )
AccessorFunc( PANEL, "SelectedItems", "SelectedItems" )
AccessorFunc( PANEL, "Spacing", "Spacing" )
	
Derma_Hook( PANEL, "Paint", "Paint", "ListBox" )

function PANEL:Init()
	self.ScrollPanel = vgui.Create( "DScrollPanel", self )
	self.ScrollPanel:SetPadding( 1  )
	self.ScrollPanel:GetVBar():SetEnabled( true )
	self.ScrollPanel:GetVBar():SetWide( 16 )
	self.ScrollPanel:Dock( FILL )
	
	self:SetMultiSelect( true )
	self:SetSpacing( 0 )
	
	self.SelectedItems = {}
end

function PANEL:AddItem( label )
	local Item = self.ScrollPanel:Add( "DListBoxDividerItem" )
	Item:SetMother( self )
	Item:SetText( label )
		-- y not
	Item:SetWide( self:GetWide() + 900 )--self.ScrollPanel:GetWide() * 2 + self.ScrollPanel:GetVBar():GetWide() )
	Item:SetPos( 0, 16 * ( #self.ScrollPanel:GetCanvas():GetChildren() - 1 ) )
	self.ScrollPanel:AddItem( Item )
	
	return Item
end

	-- Individuals ONLY
function PANEL:RemoveItem( label )
	local Output = {}

	for k,v in ipairs( self.ScrollPanel:GetCanvas():GetChildren() ) do
		if v:GetText() == label then
			v:SetSelected( false )
			self.SelectedItems = {}
		else
			Output[ #Output + 1 ] = v:GetText()
		end
	end
	
	self.ScrollPanel:Clear()
		-- need better way?!
	timer.Simple( 0, function()
		if not IsValid( self ) then return end

		for k,v in ipairs( Output ) do
			self:AddItem( v )
		end
	end )
end

function PANEL:RemoveItems( tbl )
	local Output = {}
	
		-- ew dude
	for k,v in ipairs( self.ScrollPanel:GetCanvas():GetChildren() ) do
		if table.HasValue( tbl, v:GetText() ) then
			v:SetSelected( false )
			self.SelectedItems = {}
		else
			Output[ #Output + 1 ] = v:GetText()
		end
	end
	
	self.ScrollPanel:Clear()
		-- need better way?!
	timer.Simple( 0, function()
		if not IsValid( self ) then return end

		for k,v in ipairs( Output ) do
			self:AddItem( v )
		end
	end )
end

function PANEL:Clear()
	self.SelectedItems = {}
	self.ScrollPanel:GetCanvas():Clear()
end

function PANEL:ClearSelection()
	for k,v in ipairs( self.ScrollPanel:GetCanvas():GetChildren() ) do
		v:SetSelected( false )
	end
	self.SelectedItems = {}
end

	-- not needed?
function PANEL:Rebuild()
end

function PANEL:SelectItem( item, onlyme )
	local ClearItems = true
	
	if self:GetMultiSelect() and input.IsKeyDown( KEY_LCONTROL ) then
		ClearItems = false
	elseif item:GetSelected() and #self.SelectedItems == 1 then
		ClearItems = false
	end
	
	if not self:GetMultiSelect() or ClearItems then
		self:ClearSelection()
	end

	if item:GetSelected() then
		if item.m_fClickTime and ( SysTime() - item.m_fClickTime < 0.25/*0.3*/ ) then
			if self.DoDoubleClick then self:DoDoubleClick( item ) end
		end
		
		item.m_fClickTime = SysTime()
		return
	end
	if self.OnSelect then self:OnSelect( item ) end

	item:SetSelected( true )
	item.m_fClickTime = SysTime()
	table.insert( self.SelectedItems, item )
end

function PANEL:SelectByName( label )
	for k,v in pairs( self.ScrollPanel:GetCanvas():GetChildren() ) do
		if v:GetValue() == label then
			self:SelectItem( v, true )
			return
		end
	end
end

function PANEL:GetSelectedValues()
	local Items = self:GetSelectedItems()
	
	if #Items > 1 then
		local Output = {}
		
		for k,v in pairs( Items ) do
			table.insert( Output, v:GetValue() ) 
		end
		
		return Output
	elseif #Items == 1 then
		return Items[ 1 ]:GetValue()
	end
end

function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )
	local ctrl = vgui.Create( ClassName )
	ctrl:AddItem( "Bread" )
	ctrl:AddItem( "Carrots" )
	ctrl:AddItem( "Toilet Paper" )
	ctrl:AddItem( "Air Freshnerrrr" )
	ctrl:AddItem( "Shovel" )
	for i=1,2 do
		ctrl:AddItem( "Biscuit #" .. i )
	end
	ctrl:SetSize( 150, 300 )

	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )
end	
	
derma.DefineControl( "DListBoxDividerSection", "DListBox but not based on deprecated element, also with multiselect support", PANEL, "DPanel" )


local PANEL = {}

AccessorFunc( PANEL, "m_pLeft", "Left" )
AccessorFunc( PANEL, "m_pRight", "Right" )
AccessorFunc( PANEL, "m_pMiddle", "Middle" )
AccessorFunc( PANEL, "m_sLeftTitle", "LeftTitle" )
AccessorFunc( PANEL, "m_sRightTitle", "RightTitle" )
AccessorFunc( PANEL, "m_iLeftWidth", "LeftWidth" )

surface.CreateFont( "Trebuchet36",
{
	size = 36,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "Trebuchet MS"
} )

function PANEL:Init()
	surface.SetFont( "anus_TinyText" )
	self.m_pLeft = self:Add( "DListBoxDividerSection" )
	self.m_iLeftWidth = 150
	self.m_pLeft:SetWide( self.m_iLeftWidth )
	self.m_sLeftTitle = "Left Section"
	self.m_pLeftTitle = self:Add( "DLabel" )
	self.m_pLeftTitle.TextSizeW, self.m_pLeftTitle.TextSizeH = surface.GetTextSize( self.m_sLeftTitle )
	self.m_pLeftTitle:SetFont( "anus_TinyText" )
	self.m_pLeftTitle:SetText( self.m_sLeftTitle )
	self.m_pLeftTitle:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.m_pLeftTitle:SizeToContents()
	
	surface.SetFont( "Trebuchet36" )
	
	self.m_pMiddle = self:Add( "DPanel" )
	self.m_pMiddle:SetWide( 40 )
	
	self.m_pMiddle.RightTextSizeW, self.m_pMiddle.RightTextSizeH = surface.GetTextSize( "<" )
	self.m_pMiddle.RightButton = self.m_pMiddle:Add( "anus_button" )
	self.m_pMiddle.RightButton:SetFont( "Trebuchet36" )
	self.m_pMiddle.RightButton:SetText( ">" )
	self.m_pMiddle.RightButton:SetSize( self.m_pMiddle.RightTextSizeW * 2.1, self.m_pMiddle.RightTextSizeH * 0.6 )
	self.m_pMiddle.RightButton:SetTextInset( 0, -2 )
	self.m_pMiddle.RightButton.DoClick = function( pnl )
		self:MoveItemsToRight()
	end
	
	self.m_pMiddle.LeftTextSizeW, self.m_pMiddle.LeftTextSizeH = surface.GetTextSize( ">" )
	self.m_pMiddle.LeftButton = self.m_pMiddle:Add( "anus_button" )
	self.m_pMiddle.LeftButton:SetFont( "Trebuchet36" )
	self.m_pMiddle.LeftButton:SetText( "<" )
	self.m_pMiddle.LeftButton:SetSize( self.m_pMiddle.LeftTextSizeW * 2.1, self.m_pMiddle.LeftTextSizeH * 0.6 )
	self.m_pMiddle.LeftButton:SetTextInset( 0, -2 )
	self.m_pMiddle.LeftButton.DoClick = function( pnl )
		self:MoveItemsToLeft()
	end
	
	surface.SetFont( "anus_TinyText" )
	self.m_pRight = self:Add( "DListBoxDividerSection" )
	self.m_pRight:SetWide( self.m_iLeftWidth )
	self.m_sRightTitle = "Right Section"
	self.m_pRightTitle = self:Add( "DLabel" )
	self.m_pRightTitle.TextSizeW, self.m_pRightTitle.TextSizeH = surface.GetTextSize( self.m_sRightTitle )
	self.m_pRightTitle:SetFont( "anus_TinyText" )
	self.m_pRightTitle:SetText( self.m_sRightTitle )
	self.m_pRightTitle:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.m_pRightTitle:SizeToContents()
	
	self:GetLeft().DoDoubleClick = function( pnl, item )
		self:MoveItemsToRight()
	end
	self:GetRight().DoDoubleClick = function( pnl, item )
		self:MoveItemsToLeft()
	end
		
	
	--self:SetPaintBackground( false )
end

function PANEL:Clear()
	self.m_pLeft:Clear()
	self.m_pRight:Clear()
end

function PANEL:SetLeftTitle( title )
	surface.SetFont( "anus_TinyText" )
	self.m_sLeftTitle = title
	self.m_pLeftTitle:SetText( self.m_sLeftTitle )
	self.m_pLeftTitle:SizeToContents()
	self.m_pLeftTitle.TextSizeW, self.m_pLeftTitle.TextSizeH = surface.GetTextSize( self.m_sLeftTitle )
end

function PANEL:SetRightTitle( title )
	surface.SetFont( "anus_TinyText" )
	self.m_sRightTitle = title
	self.m_pRightTitle:SetText( self.m_sRightTitle )
	self.m_pRightTitle:SizeToContents()
	self.m_pRightTitle.TextSizeW, self.m_pRightTitle.TextSizeH = surface.GetTextSize( self.m_sRightTitle )
end

function PANEL:SetLeftWidth( width )
	self.m_iLeftWidth = width
	self.m_pLeft:SetWide( width )
	
	self.m_pRight:SetWide( width )
end

function PANEL:AddLeftItem( label )
	self:GetLeft():AddItem( label )
	if self.MovedToLeft then self:MovedToLeft( label ) end
end

function PANEL:AddRightItem( label )
	self:GetRight():AddItem( label )
	if self.MovedToRight then self:MovedToRight( label ) end
end

function PANEL:MoveItemsToRight()
	local Item = self:GetLeft():GetSelectedValues()
	if not Item then return end
	
	if istable( Item ) then
		for k,v in ipairs( Item ) do
			self:AddRightItem( v )
		end
		self:GetLeft():RemoveItems( Item )
	else
		self:AddRightItem( Item )
		self:GetLeft():RemoveItem( Item )
	end
end
function PANEL:MoveItemsToLeft()
	local Item = self:GetRight():GetSelectedValues()
	if not Item then return end
	
	if istable( Item ) then
		for k,v in ipairs( Item ) do
			self:AddLeftItem( v )
		end
		self:GetRight():RemoveItems( Item )
	else
		self:AddLeftItem( Item )
		self:GetRight():RemoveItem( Item )
	end
end

function PANEL:PerformLayout()
	self:SetLeftWidth( self:GetWide() / 2 - self.m_pMiddle:GetWide() / 2 )
	
	if IsValid( self.m_pLeft ) then
		self.m_pLeft:StretchToParent( 0, 15, nil, 0 )
		self.m_pLeft:SetWide( self:GetLeftWidth() )
		self.m_pLeft:InvalidateLayout()
		
		local Additional = self:GetLeft().ScrollPanel:GetVBar().Enabled and 16 or 0
		self.m_pLeftTitle:SetPos( self:GetLeftWidth() / 2 - self.m_pLeftTitle.TextSizeW / 2, 0 )
	end
	
	if IsValid( self.m_pMiddle ) then
		self.m_pMiddle:SetPos( self:GetLeftWidth(), 15 + 1 )
		self.m_pMiddle:SetSize( self.m_pMiddle:GetWide(), self:GetTall() - ( 15 + 2 )  )
		self.m_pMiddle.LeftButton:SetPos( self.m_pMiddle:GetWide() / 2 - self.m_pMiddle.LeftButton:GetWide() / 2 + 1, self.m_pMiddle:GetTall() / 2 - ( self.m_pMiddle.LeftButton:GetTall() / 2 + 20 ) )
		self.m_pMiddle.RightButton:SetPos( self.m_pMiddle:GetWide() / 2 - self.m_pMiddle.RightButton:GetWide() / 2 + 1, self.m_pMiddle:GetTall() / 2 - ( self.m_pMiddle.RightButton:GetTall() / 2 - 20 ) )
	end
	
	if IsValid( self.m_pRight ) then
		self.m_pRight:StretchToParent( self:GetLeftWidth() + self.m_pMiddle:GetWide(), 15, 0, 0 )
		self.m_pRight:InvalidateLayout()
		
		local Additional = self:GetRight().ScrollPanel:GetVBar().Enabled and 16 or 0
		self.m_pRightTitle:SetPos( self:GetLeftWidth() / 2 - self.m_pRightTitle.TextSizeW / 2 + self:GetWide() / 2 + self.m_pMiddle:GetWide() / 2, 0 )
	end
end


function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )

	local ctrl = vgui.Create( ClassName )
	ctrl:AddLeftItem( "Bread" )
	ctrl:AddLeftItem( "Carrots" )
	ctrl:AddLeftItem( "Toilet Paper" )
	ctrl:AddRightItem( "Air Freshnerrrr" )
	ctrl:AddRightItem( "Shovel" )
	for i=1,20 do
		ctrl:AddLeftItem( "Biscuit #" .. i )
	end
	ctrl:SetWide( 450 )
	ctrl:SetTall( 250 )

	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )

end

derma.DefineControl( "DListBoxDivider", "A DList that's divided! I need a new name..", PANEL, "DPanel" )