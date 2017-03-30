	-- todo: have a window that pops up when a change to the group editor theyre in is made
	-- have it say like "this group has been modified while you were in this window. Refresh?"
	-- Close, Refresh Now buttons
	
local psizew,psizeh = nil, nil
local bgColor = Color( 231, 230, 237, 255 )

local panel = {}

--AccessorFunc( panel, "m_sGroupID", "EditableGroup", FORCE_STRING )

function panel:Init()

	--self.EditableGroup = "owner"
	self.Creations = {}
	self.Changes = {}

	self:SetSize( anus.universalWidth( 640 ), anus.universalHeight( 760 ) )
	self:Center()
	self:MakePopup()

	self.content = self:Add( "anus_contentpanel" )
	self.content:SetTitle( "Group Editor: " .. self:GetEditableGroup() )
	self.content:Dock( FILL )
	self.content.Think = function( pnl )
		for k,v in next, pnl:GetChildren() do
			v:DockMargin( 20, 40, 20, 0 )
		end
	end

	self.content.body = self.content:Add( "anus_contentpanel" )
	self.content.body:Dock( FILL )
	self.content.body.Think = function( pnl )
		for k,v in next, pnl:GetChildren() do
			v:DockMargin( 20, 0, 20, 0 )
		end
	end
	
	local body = self.content.body
	
	body.grouptabs = body:Add( "DPropertySheet" )
	body.grouptabs:Dock( FILL )
	body.grouptabs.Think = function( pnl )
		if not pnl.HasItems or #pnl.Items == 0 then return end
		
		for k,v in next, pnl.Items do
			v.Tab.Paint = function( pnl, w, h )
				local bgColor = Color( 140, 140, 140, 255 )
				if pnl:GetPropertySheet():GetActiveTab() == pnl then
					bgColor = Color( 160, 160, 160, 255 )
				end
				draw.RoundedBox( 0, 0, 0, w, h, bgColor )
			end
			
			v.Tab.UpdateColours = function( pnl, skin )
				local active = pnl:GetPropertySheet():GetActiveTab() == pnl
				
				return pnl:SetTextStyleColor( Color( 230, 230, 230, 255 ) )
			end
			
			v.Panel.Paint = function() end
		end
		
		pnl.HasItems = true
	end
		
	body.grouptabs.ScrollPanel = body.grouptabs:Add( "DScrollPanel" )
	--parent.panel.content.SheetPnl.ScrollPnl:SetSize( parent.panel.content.SheetPnl:GetSize() / 7, parent.panel.content.SheetPnl:GetTall() )
	body.grouptabs.ScrollPanel:Dock( FILL ) --LEFT )
	--[[body.grouptabs.ScrollPanel.Paint = function( pnl, w, h )
		local new_h = h
		if self.resizeNum and self.resizeNum > new_h then
			new_h = h - self.resizeNum
		elseif self.resizeNum then
			new_h = self.resizeNum
		end
		draw.RoundedBox( 0, 0, 0, w, 0, color_white )
	end]]
	body.grouptabs.ScrollPanel:SetVerticalScrollbarEnabled( true )
	
	--[[body.grouptabs.IconLayout = body.grouptabs.ScrollPanel:Add( "DIconLayout" )
	body.grouptabs.IconLayout:Dock( FILL )
	body.grouptabs.IconLayout:SetSpaceX( 5 )
	body.grouptabs.IconLayout:SetSpaceY( 5 )]]

	LocalPlayer().GroupEditorsLatest = LocalPlayer().GroupEditorsLatest or {}
	LocalPlayer().GroupEditorsLatest[ self ] = true
	
	body.grouptabs:AddSheet( "Group", self:InstallGroup() )
	body.grouptabs:AddSheet( "Privileges", self:InstallPrivileges() )
	body.grouptabs:AddSheet( "Limits", self:InstallLimits() ) 

	local old = body.grouptabs.SetActiveTab
	body.grouptabs.SetActiveTab = function( pnl, active )
		old( pnl, active )
		timer.Simple( 0, function()
			self:InvalidateLayout( true )
		end )
	end
	

	
	self.content.body.BottomButtons = self.content.body:Add( "DPanel" )
	self.content.body.BottomButtons:Dock( BOTTOM )
	
	self.content.body.BottomButtons.DiscardButton = self.content.body.BottomButtons:Add( "anus_button" )
	self.content.body.BottomButtons.DiscardButton:SetText( "Discard and Close" )
	self.content.body.BottomButtons.DiscardButton:SetSize( 50, 50 )
	self.content.body.BottomButtons.DiscardButton:Dock( RIGHT )
	self.content.body.BottomButtons.DiscardButton:SizeToContents()
	self.content.body.BottomButtons.DiscardButton.DoClick = function( pnl2 )
	if not LocalPlayer().GroupEditorsLatest then return end
	for k,v in next, LocalPlayer().GroupEditorsLatest do
		k:Remove()
		LocalPlayer().GroupEditorsLatest[ k ] = nil
	end
	end
	
		
	self.content.body.BottomButtons.SaveButton = self.content.body.BottomButtons:Add( "anus_button" )
	self.content.body.BottomButtons.SaveButton:SetText( "Save" )
	self.content.body.BottomButtons.SaveButton:SetSize( 50, 50 )
	self.content.body.BottomButtons.SaveButton:Dock( RIGHT )
	self.content.body.BottomButtons.SaveButton:DockMargin( 0, 0, 15, 0 ) 
	self.content.body.BottomButtons.SaveButton:SizeToContents()
	self.content.body.BottomButtons.SaveButton.DoClick = function( parent )
		if self.Changes[ "Group" ][ "name" ] then
			LocalPlayer():ConCommand( "anus renamegroup " .. self:GetEditableGroup() .. " " .. self.Changes[ "Group" ][ "name" ] )
		end
		
		if self.Changes[ "Group" ][ "color" ] then
			local ChangeColor = self.Changes[ "Group" ][ "color" ]
			local NewColor = Color( ChangeColor.r, ChangeColor.g, ChangeColor.b )
			LocalPlayer():ConCommand( "anus changegroupcolor " .. self.GetEditableGroup() .. " " .. tostring( NewColor ) )
		end
		
		local CombineLimitsRestrictions = {}
		CombineLimitsRestrictions[ "Spawning" ] = self.SpawnLimits
		CombineLimitsRestrictions[ "Tools" ] = self.ToolRestrictions
		
		net.Start( "anus_sv_receivegroupsettings" )
			net.WriteString( self:GetEditableGroup() )
			net.WriteTable( CombineLimitsRestrictions )
		net.SendToServer()
		
		
		
		if not LocalPlayer().GroupEditorsLatest then return end
		for k,v in next, LocalPlayer().GroupEditorsLatest do
			k:Remove()
			LocalPlayer().GroupEditorsLatest[ k ] = nil
		end
	end

end

function panel:InstallGroup()
	self.Creations[ "Group" ] = self.content.body.grouptabs.ScrollPanel:Add( "DPanel" )
	self.Changes[ "Group" ] = {}
	
	local pnl = self.Creations[ "Group" ]
	
	pnl.Header = pnl:Add( "DPanel" )
	pnl.Header:SetTall( 140 )
	pnl.Header:Dock( TOP )
	pnl.Header.Paint = function() end
	
	--[[pnl.Header.RankName = pnl.Header:Add( "DTextEntry", pnl.Header )
	pnl.Header.RankName:Dock( FILL )
	pnl.Header.RankName:SetTall( 31 )
	pnl.Header.RankName:DockMargin( 0, 4, 50, 25 )
	pnl.Header.RankName:SetTextInset( 10, 0 )
	
	pnl.Header.RankDerive = pnl.Header:Add( "DComboBox", pnl.Header )
	pnl.Header.RankDerive:SetTall( 32 )
	pnl.Header.RankDerive:Dock( LEFT )
	pnl.Header.RankDerive:DockMargin( 0, 4, 0, 0 )]]
	
	pnl.Row1 = pnl.Header:Add( "DPanel" )
	pnl.Row1:SetTall( 50 )
	pnl.Row1:Dock( TOP )
	pnl.Row1.Paint = function( parent, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 100, 200, 0, 150 ) )
	end

	pnl.Row2 = pnl.Row1:Add( "DPanel" )
	pnl.Row2:SetTall( 20 ) 
	pnl.Row2:Dock( TOP )
	pnl.Row2.Paint = function( parent, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 100, 0, 40, 150 ) ) 
	end

	surface.SetFont( "anus_SmallText" )

	pnl.Row2.NameLabel2 = pnl.Row2:Add( "DLabel" )
	pnl.Row2.NameLabel2:SetFont( "anus_SmallText" )
	pnl.Row2.NameLabel2:SetText( "Group Name" )
	pnl.Row2.NameLabel2:SetTextColor( Color( 0, 0, 0, 255 ) )
	pnl.Row2.NameLabel2:Dock( LEFT )
	pnl.Row2.NameLabel2:SetTextInset( 15, 0 )
	pnl.Row2.NameLabel2:SizeToContents()
	
	local TextSizeW, TextSizeH = surface.GetTextSize( "Group ID" )
	pnl.Row2.Unique2 = pnl.Row2:Add( "DLabel" )
	pnl.Row2.Unique2:SetFont( "anus_SmallText" )
	pnl.Row2.Unique2:SetText( "Group ID" )
	pnl.Row2.Unique2:SetTextColor( Color( 0, 0, 0, 255 ) )
	pnl.Row2.Unique2:Dock( RIGHT ) 
	pnl.Row2.Unique2:DockMargin( 0, 0, 15 + 100 - TextSizeW, 0 )
	pnl.Row2.Unique2:SizeToContents()

	pnl.Row1.NameLabel = pnl.Row1:Add( "DTextEntry" )
	pnl.Row1.NameLabel.DefaultText = anus.Groups[ self:GetEditableGroup() ].name
	pnl.Row1.NameLabel:SetText( anus.Groups[ self:GetEditableGroup() ].name )
	pnl.Row1.NameLabel:SetFont( "anus_TinyText" )
	pnl.Row1.NameLabel:SetWide( 100 )
	pnl.Row1.NameLabel:Dock( LEFT )
	pnl.Row1.NameLabel:DockMargin( 15, 0, 0, 5 ) 
	pnl.Row1.NameLabel.OnChange = function( parent )
		print( "ello1" )
		if parent:GetText() != parent.DefaultText then
			self.Changes[ "Group" ][ "name" ] = parent:GetText()
		else
			self.Changes[ "Group" ][ "name" ] = nil
		end
	end
	 
	pnl.Row1.Unique = pnl.Row1:Add( "DTextEntry" )
	pnl.Row1.Unique.DefaultText = self:GetEditableGroup()
	pnl.Row1.Unique:SetText( self:GetEditableGroup() )
	pnl.Row1.Unique:SetFont( "anus_TinyText" )
	pnl.Row1.Unique:SetWide( 100 )  
	pnl.Row1.Unique:Dock( RIGHT )
	pnl.Row1.Unique:DockMargin( 0, 0, 15, 5 )    
	if anus.Groups[ self:GetEditableGroup() ].hardcoded then
		pnl.Row1.Unique:SetDisabled( true )
	end
	pnl.Row1.Unique.OnEnter = function( parent )
		if parent:GetText() != parent.DefaultText then
			self.Changes[ "Group" ][ "id" ] = parent:GetText()
		else
			self.Changes[ "Group" ][ "id" ] = nil
		end
	end
	
	
	
	pnl.Row3 = pnl.Header:Add( "DPanel" )
	pnl.Row3:SetTall( 50 )
	pnl.Row3:Dock( TOP )
	pnl.Row3.Paint = function( parent, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 100, 200, 0, 150 ) )
	end
	
	pnl.Row4 = pnl.Row3:Add( "DPanel" )
	pnl.Row4:SetTall( 20 ) 
	pnl.Row4:Dock( TOP )
	pnl.Row4.Paint = function( parent, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 100, 0, 40, 150 ) ) 
	end

	pnl.Row4.NameLabel2 = pnl.Row4:Add( "DLabel" )
	pnl.Row4.NameLabel2:SetFont( "anus_SmallText" )
	pnl.Row4.NameLabel2:SetText( "Placeholder Text" )
	pnl.Row4.NameLabel2:SetTextColor( Color( 0, 0, 0, 255 ) )
	pnl.Row4.NameLabel2:Dock( LEFT )
	pnl.Row4.NameLabel2:SetTextInset( 15, 0 )
	pnl.Row4.NameLabel2:SizeToContents()
	
	TextSizeW, TextSizeH = surface.GetTextSize( "Inheritance" )
	pnl.Row4.Unique2 = pnl.Row4:Add( "DLabel" )
	pnl.Row4.Unique2:SetFont( "anus_SmallText" )
	pnl.Row4.Unique2:SetText( "Inheritance" )
	pnl.Row4.Unique2:SetTextColor( Color( 0, 0, 0, 255 ) )
	pnl.Row4.Unique2:Dock( RIGHT ) 
	pnl.Row4.Unique2:DockMargin( 0, 0, 15 + 100 - TextSizeW, 0 )
	pnl.Row4.Unique2:SizeToContents()

	pnl.Row3.NameLabel = pnl.Row3:Add( "DComboBox" )
	pnl.Row3.NameLabel:SetWide( 100 )
	pnl.Row3.NameLabel:Dock( LEFT )
	pnl.Row3.NameLabel:DockMargin( 15, 0, 0, 5 ) 
	
	pnl.Row3.Unique = pnl.Row3:Add( "DComboBox" )
	pnl.Row3.Unique:SetWide( 100 )
	pnl.Row3.Unique:Dock( RIGHT )
	pnl.Row3.Unique:DockMargin( 0, 0, 15, 5 )
	if anus.Groups[ self:GetEditableGroup() ].Inheritance then
		pnl.Row3.Unique:SetValue( anus.Groups[ self:GetEditableGroup() ].Inheritance )
	end
	for k,v in next, anus.Groups do
		if self:GetEditableGroup() == k then continue end
		pnl.Row3.Unique:AddChoice( k )
	end
	
	pnl.ColorText = pnl:Add( "DLabelEditable" )
	pnl.ColorText:SetFont( "anus_SmallText" )
	pnl.ColorText:SetText( anus.Groups[ self:GetEditableGroup() ].name )
	pnl.ColorText:SetTextColor( Color( 0, 0, 0, 255 ) )
	pnl.ColorText:Dock( TOP )
	pnl.ColorText:SetTextInset( 15, 0 )
	pnl.ColorText:SizeToContents()
	
	pnl.ColorMixer = pnl:Add( "DColorMixer" )
	pnl.ColorMixer:Dock( FILL )
	pnl.ColorMixer:DockMargin( 15, 5, 15, 5 ) 
	pnl.ColorMixer:SetAlphaBar( false )
	local GroupColor = anus.Groups[ self:GetEditableGroup() ].color
	local NewColor = Color( GroupColor.a, GroupColor.g, GroupColor.b, 255 )
	pnl.ColorMixer.DefaultColor = NewColor
	pnl.ColorMixer.ValueChanged = function( parent, col )
		pnl.ColorText:SetTextColor( col )
		
		if parent:GetColor() != parent.DefaultColor then
			self.Changes[ "Group" ][ "color" ] = parent:GetColor()
		else
			self.Changes[ "Group" ][ "color" ] = nil
		end
	end
	pnl.ColorMixer:SetColor( anus.Groups[ self:GetEditableGroup() ].color )
	
	return self.Creations[ "Group" ]
end

function panel:InstallPrivileges()
	self.Creations[ "Privileges" ] = self.content.body.grouptabs.ScrollPanel:Add( "DPanel" )
	
	local pnl = self.Creations[ "Privileges" ]
	
	
	
	return self.Creations[ "Privileges" ]
end

function panel:InstallLimits()
	self.Creations[ "Limits" ] = self.content.body.grouptabs.ScrollPanel:Add( "DPanel" ) --self.content.body.grouptabs.IconLayout:Add( "DPanel" ) --self.content.body.grouptabs.ScrollPanel:Add( "DPanel" )
	
	local pnl = self.Creations[ "Limits" ]
	
	pnl.ScrollPanel = pnl:Add( "DScrollPanel" )
	pnl.ScrollPanel:Dock( FILL )
	pnl.ScrollPanel:SetVerticalScrollbarEnabled( true )
	
	pnl.ColorText = pnl.ScrollPanel:Add( "DLabel" )
	pnl.ColorText:SetFont( "anus_SmallText" )
	pnl.ColorText:SetText( "Spawn Limits" )
	pnl.ColorText:SetTextColor( Color( 0, 0, 0, 255 ) )
	pnl.ColorText:Dock( TOP )
	pnl.ColorText:SetTextInset( 15, 0 )
	pnl.ColorText:SizeToContents()
	
	pnl.body1 = pnl.ScrollPanel:Add( "anus_contentpanel" )--self.content.body.grouptabs.ScrollPanel:AddItem( "anus_contentpanel" )--:Add( "anus_contentpanel" )
	pnl.body1:Dock( TOP )
	pnl.body1:DockMargin( 15, 4, 15, 4 )  
	pnl.body1:SetTall( 450 + 15 - 60 )
	pnl.body1.Think = function() end
	
	local SpawnLimits = {}
	local SpawnHolderTbl = {}
	self.SpawnLimits = {}
	local function RegisterNewSpawnLimit( header, convar, min, max )
		local NewHeader = header:gsub( " ", "_" ):lower()
		SpawnLimits[ NewHeader ] = { min = min or 0, max = max or 255 }
		self.SpawnLimits[ NewHeader ] = { custom = false }
		
		local SpawnLabel = pnl.body1:Add( "DLabel" )
		SpawnLabel:SetText( header )
		SpawnLabel:SetFont( "anus_TinyText" )
		SpawnLabel:SetTextColor( Color( 0, 0, 0, 255 ) )
		SpawnLabel:Dock( TOP )
		SpawnLabel:SetTextInset( 15, 0 )
		SpawnLabel:SizeToContents()
		
		SpawnHolderTbl[ NewHeader ] = { header = SpawnLabel }
		
		local SpawnBodyMaster = pnl.body1:Add( "DPanel" )
		SpawnBodyMaster:Dock( TOP )
		SpawnBodyMaster:DockMargin( 15, 4, 15, 4 )
		SpawnBodyMaster:SetTall( 40 )
		SpawnBodyMaster.Paint = function( parent, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, 255 ) )
			local Background = Color( 255, 235, 235, 255 )
			parent.Disabled = true
			if SpawnHolderTbl[ NewHeader ].checkbox and SpawnHolderTbl[ NewHeader ].checkbox:GetChecked() then
				Background = color_white
				parent.Disabled = false
			end
			draw.RoundedBox( 0, 1, 1, w - 2, h - 2, Background )
		end
		
		SpawnHolderTbl[ NewHeader ].bodymaster = SpawnBodyMaster
		
		local SpawnOverrideBody = SpawnBodyMaster:Add( "DPanel" )
		SpawnOverrideBody:Dock( LEFT )
		SpawnOverrideBody:SetWide( 120 )
		SpawnOverrideBody.Paint = function( parent, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, 255 ) )
			draw.RoundedBox( 0, 1, 1, w - 2, h - 2, color_white )
		end
		
		surface.SetFont( "anus_TinyText" )
		
		local TextSizeW, TextSizeH = surface.GetTextSize( "Override Default" )
		local SpawnOverrideText = SpawnOverrideBody:Add( "DLabel" )
		SpawnOverrideText:SetText( "Override Default" )
		SpawnOverrideText:SetFont( "anus_TinyText" )
		SpawnOverrideText:SetTextColor( Color( 0, 0, 0, 255 ) )
		SpawnOverrideText:Dock( TOP )
		SpawnOverrideText:SetTextInset( math.abs( TextSizeW / 2 - SpawnOverrideBody:GetWide() / 2 ), 0 )
		SpawnOverrideText:SizeToContents()
		
		local SpawnOverrideCheckBox = SpawnOverrideBody:Add( "DCheckBox" )
		SpawnOverrideCheckBox:SetValue( 0 )
		SpawnOverrideCheckBox:Dock( TOP )
		SpawnOverrideCheckBox:DockMargin( 50, 4, 50, 0 )
		SpawnOverrideCheckBox.OnChange = function( parent, val )
			if not val then
				SpawnHolderTbl[ NewHeader ].slider.Slider.OldSlideX = SpawnHolderTbl[ NewHeader ].slider.Slider:GetSlideX()
			end

			self.SpawnLimits[ NewHeader ].custom = val
			if val == true then
				self.SpawnLimits[ NewHeader ].limit = SpawnHolderTbl[ NewHeader ].slider.TextArea:GetText()
			end
		end
		
		SpawnHolderTbl[ NewHeader ].checkbox = SpawnOverrideCheckBox
		
		local SpawnSlider = SpawnBodyMaster:Add( "DNumSlider" )
		SpawnSlider:Dock( FILL )
		SpawnSlider:DockMargin( 15, 0, 15, 0 )
		SpawnSlider:SetMin( min or 0 )
		SpawnSlider:SetMax( max or 255 )
		SpawnSlider:SetValue( GetConVarNumber( convar ) )
		SpawnSlider:SetDecimals( 0 )
		SpawnSlider.Label:Dock( NODOCK )
		SpawnSlider.Label:SetSize( 1, 1 )
		SpawnSlider.TextArea.DefaultText = SpawnSlider.TextArea:GetText()
		SpawnSlider.TextArea.OldOnChange = SpawnSlider.TextArea.OnChange
		SpawnSlider.TextArea.OnChange = function( parent, val, test )
			if SpawnBodyMaster.Disabled then
				parent:SetText( parent.DefaultText )
				return
			end

			self.SpawnLimits[ NewHeader ].limit = parent:GetText()
			parent.OldOnChange( parent, val )
		end
		SpawnSlider.OldValueChanged = SpawnSlider.ValueChanged
		SpawnSlider.ValueChanged = function( parent, val )
			if SpawnBodyMaster.Disabled then return end
			
			self.SpawnLimits[ NewHeader ].limit = math.Round( val )
			parent.OldValueChanged( parent, val ) 
		end
		hook.Add( "Think", SpawnSlider, function()
			if SpawnBodyMaster.Disabled then 
				SpawnSlider.Slider:SetSlideX( SpawnSlider.Slider.OldSlideX or 0 )
			end
		end )

		SpawnHolderTbl[ NewHeader ].slider = SpawnSlider
	end

	RegisterNewSpawnLimit( "Props", "sbox_maxprops", 0, 500 )
	RegisterNewSpawnLimit( "Effects", "sbox_maxeffects" )
	RegisterNewSpawnLimit( "Vehicles", "sbox_maxvehicles" )
	RegisterNewSpawnLimit( "NPCs", "sbox_maxnpcs" )
	RegisterNewSpawnLimit( "SENTs", "sbox_maxsents" )
	RegisterNewSpawnLimit( "Ragdolls", "sbox_maxragdolls" )


	pnl.ToolsLabel = pnl.ScrollPanel:Add( "DLabel" )
	pnl.ToolsLabel:SetFont( "anus_SmallText" )
	pnl.ToolsLabel:SetText( "Tool Restrictions" )
	pnl.ToolsLabel:SetTextColor( Color( 0, 0, 0, 255 ) )
	pnl.ToolsLabel:Dock( TOP )
	pnl.ToolsLabel:SetTextInset( 15, 0 )
	pnl.ToolsLabel:SizeToContents()

	pnl.body2 = pnl.ScrollPanel:Add( "anus_contentpanel" )
	pnl.body2:Dock( TOP )
	pnl.body2:DockMargin( 15, 4, 15, 4 )
	pnl.body2:SetTall( 15 + 20 )  
	pnl.body2.Think = function() end
	
	local ToolHolderTbl = {}
	local BodySize = 0
	local Gap = 8
	self.ToolRestrictions = {}
	local function RegisterNewToolRestriction( header, itemname, toolname, b_on )
		BodySize = BodySize + 24 + Gap
		ToolHolderTbl[ itemname ] = { header = header, toggled = b_on }
		self.ToolRestrictions[ toolname ] = b_on and 1 or 0
	
		local BodyMaster = pnl.body2:Add( "DPanel" )
		BodyMaster:Dock( TOP )
		BodyMaster:DockMargin( 15, 0, 15, Gap ) 
		BodyMaster:SetTall( 24 )
		BodyMaster.Paint = function( parent, w, h )
			--draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, 255 ) )
			--draw.RoundedBox( 0, 1, 1, w - 2, h - 2, color_white )
		end
		
		ToolHolderTbl[ itemname ].bodymaster = BodyMaster
		
		local BodyLabel = BodyMaster:Add( "DLabel" )
		BodyLabel:SetFont( "anus_TinyText" )
		BodyLabel:SetText( header )
		BodyLabel:SetTextInset( 5, 0 )
		BodyLabel:SetTextColor( Color( 0, 0, 0, 255 ) )
		BodyLabel:Dock( LEFT )
		BodyLabel:SizeToContents()
		
		local BodyImage = BodyMaster:Add( "DImageButton" )
		BodyImage:SetImage( b_on and "icon16/accept.png" or "icon16/cancel.png" )
		BodyImage:SetSize( 16, 16 )
		BodyImage:Dock( RIGHT )
		BodyImage:DockMargin( 0, 3, 5, 3 )
		BodyImage.DoClick = function( parent )
			ToolHolderTbl[ itemname ].toggled = not ToolHolderTbl[ itemname ].toggled
			self.ToolRestrictions[ toolname ] = ToolHolderTbl[ itemname ].toggled and 1 or 0
			BodyImage:SetImage( ToolHolderTbl[ itemname ].toggled and "icon16/accept.png" or "icon16/cancel.png" )
		end
		
		ToolHolderTbl[ itemname ].bodyimage = BodyImage
	end
	
		-- lua_run_cl PrintTable( spawnmenu.GetTools() )
		-- lua_run_cl PrintTable( weapons.Get( "gmod_tool" ).Tool )
	local SortTools = {}
	for k,v in next, weapons.Get( "gmod_tool" ).Tool do
		if not v.Category or v.Category == "My Category" then continue end
		SortTools[ #SortTools + 1 ] = { name = v.Name:gsub( "#", "" ), toolname = k, category = v.Category } 
	end
	table.SortByMember( SortTools, "category", true )
	
	for k,v in ipairs( SortTools ) do
		RegisterNewToolRestriction( v.category .. " - " .. language.GetPhrase( string.sub( v.name, 1, #v.name ) ), v.name, v.toolname, true )
	end 
	pnl.body2:SetTall( pnl.body2:GetTall() + BodySize )
	
	
		-- http://prntscr.com/d6y078 ?
	--[[pnl.WeaponName = pnl.ScrollPanel:Add( "DLabel" )
	pnl.WeaponName:SetFont( "anus_SmallText" )
	pnl.WeaponName:SetText( "Weapon Spawn Restrictions" )
	pnl.WeaponName:SetTextColor( Color( 0, 0, 0, 255 ) )
	pnl.WeaponName:Dock( TOP )
	pnl.WeaponName:SetTextInset( 15, 0 )
	pnl.WeaponName:SizeToContents()
	
	pnl.body3 = pnl.ScrollPanel:Add( "anus_contentpanel" )
	pnl.body3:Dock( TOP )
	pnl.body3:DockMargin( 15, 4, 15, 4 )
	pnl.body3:SetTall( 90 )  
	pnl.body3.Think = function() end]]
	
	return self.Creations[ "Limits" ]
end

function panel:PerformLayout( w, h )

	if not self.content.body.grouptabs.m_pActiveTab then return end

	local tabName = self.content.body.grouptabs.m_pActiveTab:GetText()
	
	
end

function panel:SetEditableGroup( group )
	self.EditableGroup = group
end
function panel:GetEditableGroup()
	return self.EditableGroup or "owner"
end
	
concommand.Add( "closegroupeditorlatest", function()
	if not LocalPlayer().GroupEditorsLatest then return end
	for k,v in next, LocalPlayer().GroupEditorsLatest do
		k:Remove()
		LocalPlayer().GroupEditorsLatest[ k ] = nil
	end
end )

function panel:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, 255 ) ) 
	draw.RoundedBox( 0, 1, 1, w - 2, h - 2, color_white )
	
	--print( self.EditableGroup )
end
	
vgui.Register( "anus_groupeditor_latest", panel, "EditablePanel" )