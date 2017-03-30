local PANEL = {}

--Derma_Hook( PANEL, "Paint", "Paint", "TextEntry" )--"ComboBox" )

Derma_Install_Convar_Functions( PANEL )

AccessorFunc( PANEL, "m_bDoSort", "SortItems", FORCE_BOOL )
	-- dependent on TextEntry
AccessorFunc( PANEL, "m_colHighlight", "HighlightColor" )
AccessorFunc( PANEL, "m_colCursor", "CursorColor" )
AccessorFunc( PANEL, "m_bBorder", "DrawBorder" )
AccessorFunc( PANEL, "m_bBackground", "PaintBackground" )
AccessorFunc( PANEL, "m_FontName", "Font" )
	-- ported from DFrame, required
AccessorFunc( PANEL, "m_bIsMenuComponent",	"IsMenu",			FORCE_BOOL )

function PANEL:Init()

	self.DropButton = vgui.Create( "DImageButton", self )
	self.DropButton.Paint = function( panel, w, h ) derma.SkinHook( "Paint", "ComboDownArrow", panel, w, h ) end
	self.DropButton:SetMouseInputEnabled( true )
	self.DropButton.ComboBox = self
	self.DropButton.ComboBoxEditable = true
	self.DropButton.DoClick = function( pnl )
		if ( self:IsMenuOpen() ) then
			return self:CloseMenu()
		end

		self:OpenMenu()
	end
		
	self:SetTall( 22 )
	self:Clear()

	self:SetContentAlignment( 4 )
	self:SetTextInset( 8, 0 )
	self:SetIsMenu( true )
	self:SetSortItems( true )
	
		-- DTextEntry
	self:SetCursor( "beam" )
	self:SetPaintBorderEnabled( false )
	self:SetPaintBackgroundEnabled( false )
	self:SetDrawBorder( true )
	self:SetPaintBackground( true )
	self:SetPaintBorderEnabled( true )
	self:SetFont( "DermaDefault" )
		-- Clear keyboard focus when we click away 
	self.m_bLoseFocusOnClickAway = true
	
	if self:GetSkin().GwenTexture and self:GetSkin().GwenTexture:GetName() == "gwenskin/gmoddefault" then
		self:ModifyDropSkin()
	end

end

function PANEL:Clear()

	self:SetText( "" )
	self.Choices = {}
	self.Data = {}

	if ( self.Menu ) then
		self.Menu:Remove()
		self.Menu = nil
	end

end

function PANEL:ModifyDropSkin()
	local skin = self:GetSkin()
	
	skin.PaintComboDownArrow = function( pnl, panel, w, h )

		if ( panel.ComboBox:GetDisabled() ) then 
			return pnl.tex.Input.ComboBox.Button.Disabled( 0, 0, w, h )
		end

		if ( panel.ComboBox.Depressed || panel.ComboBox:IsMenuOpen() ) and panel.ComboBoxEditable then
			local ComboBox_Button_Down = GWEN.CreateTextureNormal( 481, 256, 14, 15 ) 
			return ComboBox_Button_Down( 0, 0, w, h ) 
		elseif ( panel.ComboBox.Depressed || panel.ComboBox:IsMenuOpen() ) then
			return pnl.tex.Input.ComboBox.Button.Down( 0, 0, w, h )
		end

		if ( panel.ComboBox.Hovered ) then
			return pnl.tex.Input.ComboBox.Button.Hover( 0, 0, w, h )
		end

		pnl.tex.Input.ComboBox.Button.Normal( 0, 0, w, h )

	end

	self.DropButton.Paint = function( panel, w, h ) derma.SkinHook( "Paint", "ComboDownArrow", panel, w, h ) end
end

function PANEL:GetOptionText( id )

	return self.Choices[ id ]

end

function PANEL:GetOptionData( id )

	return self.Data[ id ]

end

function PANEL:GetOptionTextByData( data )

	for id, dat in pairs( self.Data ) do
		if ( dat == data ) then
			return self:GetOptionText( id )
		end
	end

	-- Try interpreting it as a number
	for id, dat in pairs( self.Data ) do
		if ( dat == tonumber( data ) ) then
			return self:GetOptionText( id )
		end
	end

	-- In case we fail
	return data

end

function PANEL:PerformLayout()

	self.DropButton:SetSize( 16, 16 )--15, 15 )
	self.DropButton:AlignRight( 4 )
	self.DropButton:CenterVertical()

		-- DTextEntry
	derma.SkinHook( "Layout", "TextEntry", self )
end

function PANEL:ChooseOption( value, index )

	if ( self.Menu ) then
		self.Menu:Remove()
		self.Menu = nil
	end

	self:SetText( value )

	-- This should really be the here, but it is too late now and convar changes are handled differently by different child elements
	--self:ConVarChanged( self.Data[ index ] )

	self.selected = index
	self:OnSelect( index, value, self.Data[ index ] )

end

function PANEL:ChooseOptionID( index )

	local value = self:GetOptionText( index )
	self:ChooseOption( value, index )

end

function PANEL:GetSelectedID()

	return self.selected

end

function PANEL:GetSelected()

	if ( !self.selected ) then return end

	return self:GetOptionText( self.selected ), self:GetOptionData( self.selected )

end

function PANEL:OnSelect( index, value, data )

	-- For override

end

function PANEL:AddChoice( value, data, select, location )

	local i 
	if location then
		i = table.insert( self.Choices, location, value )
	else
		i = table.insert( self.Choices, value )
	end

	if ( data ) then
		self.Data[ i ] = data
	end

	if ( select ) then

		self:ChooseOption( value, i )

	end

	return i

end

function PANEL:IsMenuOpen()

	return IsValid( self.Menu ) && self.Menu:IsVisible()

end

function PANEL:OpenMenu( pControlOpener )

	if ( pControlOpener && pControlOpener == self.TextEntry ) then
		return
	end

	-- Don't do anything if there aren't any options..
	if ( #self.Choices == 0 ) then return end

	-- If the menu still exists and hasn't been deleted
	-- then just close it and don't open a new one.
	if ( IsValid( self.Menu ) ) then
		self.Menu:Remove()
		self.Menu = nil
	end

	self.Menu = DermaMenu( false, self )

	if ( self:GetSortItems() ) then
		local sorted = {}
		for k, v in pairs( self.Choices ) do
			local val = tostring( v ) --tonumber( v ) || v -- This would make nicer number sorting, but SortedPairsByMemberValue doesn't seem to like number-string mixing
			if ( isstring( val ) && string.len( val ) > 1 && !tonumber( val ) ) then val = language.GetPhrase( val:sub( 2 ) ) end
			table.insert( sorted, { id = k, data = v, label = val } )
		end
		for k, v in SortedPairsByMemberValue( sorted, "label" ) do
			self.Menu:AddOption( v.data, function() self:ChooseOption( v.data, v.id ) end )
		end
	else
		for k, v in pairs( self.Choices ) do
			self.Menu:AddOption( v, function() self:ChooseOption( v, k ) end )
		end
	end

	local x, y = self:LocalToScreen( 0, self:GetTall() )

	self.Menu:SetMinimumWidth( self:GetWide() )
	self.Menu:Open( x, y )--, false, self )

end

function PANEL:CloseMenu()

	if ( IsValid( self.Menu ) ) then
		self.Menu:Remove()
	end

end

-- This really should use a convar change hook
function PANEL:CheckConVarChanges()

	if ( !self.m_strConVar ) then return end

	local strValue = GetConVarString( self.m_strConVar )
	if ( self.m_strConVarValue == strValue ) then return end

	self.m_strConVarValue = strValue

	self:SetValue( self:GetOptionTextByData( self.m_strConVarValue ) )

end

function PANEL:Think()

	self:CheckConVarChanges()

end

function PANEL:SetValue( strValue )

	self:SetText( strValue )

end

function PANEL:DoClick()

	self:StartBoxSelection()

end

-- Start dependency on TextEntry
function PANEL:Paint( w, h )
	derma.SkinHook( "Paint", "TextEntry", self, w, h )
	return false
end

function PANEL:ApplySchemeSettings()

	self:SetFontInternal( self.m_FontName )

	derma.SkinHook( "Scheme", "TextEntry", self )

end

function PANEL:GetTextColor()

	return self.m_colText || self:GetSkin().colTextEntryText

end

function PANEL:GetDisabled()
	return false
end


function PANEL:GetHighlightColor()

	return self.m_colHighlight || self:GetSkin().colTextEntryTextHighlight

end

function PANEL:GetCursorColor()

	return self.m_colCursor || self:GetSkin().colTextEntryTextCursor

end
-- End dependency


function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )

	local ctrl = vgui.Create( ClassName )
	ctrl:AddChoice( "Some Choice" )
	ctrl:AddChoice( "Another Choice" )
	ctrl:SetWide( 150 )

	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )

end

derma.DefineControl( "DComboBoxEditable", "An editable DComboBox", PANEL, "DTextEntry" )