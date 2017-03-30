	-- todo: have a window that pops up when a change to the group editor theyre in is made
	-- have it say like "this group has been modified while you were in this window. Refresh?"
	-- Close, Refresh Now buttons
	
local psizew,psizeh = nil, nil
local bgColor = Color( 231, 230, 237, 255 )

function anusBaseGroupEditor( base, groupid )
	base.Creations[ "Group" ] = base.content.body.grouptabs.ScrollPanel:Add( "DPanel" )
	base.Changes[ "Group" ] = {}
	
	local pnl = base.Creations[ "Group" ]
	
	pnl.ScrollPanel = pnl:Add( "DScrollPanel" )
	pnl.ScrollPanel:Dock( FILL )
	pnl.ScrollPanel:SetVerticalScrollbarEnabled( true )
	
	pnl.Header = pnl.ScrollPanel:Add( "DPanel" )
	pnl.Header:SetTall( 120 ) 
	pnl.Header:Dock( TOP )
	pnl.Header.Paint = function() end
	
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
	pnl.Row1.NameLabel.DefaultText = groupid and anus.Groups[ groupid ].name or ""
	pnl.Row1.NameLabel:SetText( pnl.Row1.NameLabel.DefaultText )
	pnl.Row1.NameLabel:SetFont( "anus_TinyText" )
	pnl.Row1.NameLabel:SetWide( 100 )
	pnl.Row1.NameLabel:Dock( LEFT )
	pnl.Row1.NameLabel:DockMargin( 15, 0, 0, 5 ) 
	pnl.Row1.NameLabel.OnChange = function( parent )
		if parent:GetText() != parent.DefaultText then
			base.Changes[ "Group" ][ "name" ] = parent:GetText()
		else
			base.Changes[ "Group" ][ "name" ] = nil
		end
	end
	 
	pnl.Row1.Unique = pnl.Row1:Add( "DTextEntry" )
	pnl.Row1.Unique.DefaultText = groupid or ""
	pnl.Row1.Unique:SetText( pnl.Row1.Unique.DefaultText )
	pnl.Row1.Unique:SetFont( "anus_TinyText" )
	pnl.Row1.Unique:SetWide( 100 )  
	pnl.Row1.Unique:Dock( RIGHT )
	pnl.Row1.Unique:DockMargin( 0, 0, 15, 5 )    
	if groupid and anus.Groups[ groupid ].hardcoded then
		pnl.Row1.Unique:SetDisabled( true )
	end
	pnl.Row1.Unique.OnChange = function( parent )
		if parent:GetText() != parent.DefaultText then
			base.Changes[ "Group" ][ "id" ] = parent:GetText()
		else
			base.Changes[ "Group" ][ "id" ] = nil
		end
	end
	
	
	
	pnl.Row3 = pnl.Header:Add( "DPanel" )
	pnl.Row3:SetTall( 50 )
	pnl.Row3:Dock( TOP )
	pnl.Row3.Paint = function( parent, w, h ) end
	
	pnl.Row4 = pnl.Row3:Add( "DPanel" )
	pnl.Row4:SetTall( 20 ) 
	pnl.Row4:Dock( TOP )
	pnl.Row4.Paint = function( parent, w, h ) end

	pnl.Row4.NameLabel2 = pnl.Row4:Add( "DLabel" )
	pnl.Row4.NameLabel2:SetFont( "anus_SmallText" )
	pnl.Row4.NameLabel2:SetText( "Can Target" )
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

	pnl.Row3.NameLabel = pnl.Row3:Add( "DTextEntry" )
	pnl.Row3.NameLabel.DefaultText = groupid and anus.Groups[ groupid ].can_target or "*"
	if string.sub( pnl.Row3.NameLabel.DefaultText, 1, 1 ) == "#" then
		pnl.Row3.NameLabel.DefaultText = "#" .. pnl.Row3.NameLabel.DefaultText
	end
	pnl.Row3.NameLabel:SetText( pnl.Row3.NameLabel.DefaultText )
	pnl.Row3.NameLabel:SetFont( "anus_TinyText" )
	pnl.Row3.NameLabel:SetWide( 100 )
	pnl.Row3.NameLabel:Dock( LEFT )
	pnl.Row3.NameLabel:DockMargin( 15, 0, 0, 5 ) 
	pnl.Row3.NameLabel.OnChange = function( parent )
		if parent:GetText() != parent.DefaultText then
			base.Changes[ "Group" ][ "can_target" ] = parent:GetText()
		else
			base.Changes[ "Group" ][ "can_target" ] = nil
		end
	end
	
	pnl.Row3.Unique = pnl.Row3:Add( "DComboBox" )
	pnl.Row3.Unique:SetWide( 100 )
	pnl.Row3.Unique:Dock( RIGHT )
	pnl.Row3.Unique:DockMargin( 0, 0, 15, 5 )
	if groupid and anus.Groups[ groupid ].Inheritance then
		pnl.Row3.Unique:SetValue( anus.Groups[ groupid ].Inheritance )
		pnl.Row3.Unique.DefaultInheritance = anus.Groups[ groupid ].Inheritance
	else
		pnl.Row3.Unique:SetValue( "user" )
		pnl.Row3.Unique.DefaultInheritance = "user"
	end
	for k,v in next, anus.Groups do
		if groupid == k then continue end
		pnl.Row3.Unique:AddChoice( k )
	end
	if groupid == "user" then
		pnl.Row3.Unique:SetDisabled( true ) 
	end
	base.Changes[ "Group" ][ "inheritance" ] = pnl.Row3.Unique.DefaultInheritance
	pnl.Row3.Unique.OnSelect = function( parent, index, val, data )
		if (val == parent.DefaultInheritance) and groupid then return end

		base.Changes[ "Group" ][ "inheritance" ] = val
	end
	
	if not groupid then goto Finish end
	
	pnl.body1 = pnl.ScrollPanel:Add( "anus_contentpanel" )
	pnl.body1:Dock( TOP )
	pnl.body1:DockMargin( 15, 0, 15, 4 )   
	pnl.body1:SetTall( 450 + 15 - 60 )
	pnl.body1.Think = function() end
	
	pnl.ColorText = pnl.body1:Add( "DLabelEditable" )
	pnl.ColorText:SetFont( "anus_SmallText" )
	pnl.ColorText:SetText( groupid and anus.Groups[ groupid ].name or "" )
	pnl.ColorText:SetTextColor( Color( 0, 0, 0, 255 ) )
	pnl.ColorText:Dock( TOP )
	pnl.ColorText:SetTextInset( 15, 0 )
	pnl.ColorText:SizeToContents()
	
	pnl.ColorMixer = pnl.body1:Add( "DColorMixer" )
	pnl.ColorMixer:Dock( FILL )
	pnl.ColorMixer:DockMargin( 15, 5, 15, 5 ) 
	pnl.ColorMixer:SetAlphaBar( false )
	pnl.ColorMixer.DefaultColor = groupid and anus.Groups[ groupid ].color or color_white
	pnl.ColorMixer.ValueChanged = function( parent, col )
		pnl.ColorText:SetTextColor( col )
		
		if col != parent.DefaultColor then
			base.Changes[ "Group" ][ "color" ] = col
		else
			base.Changes[ "Group" ][ "color" ] = nil
		end
	end	
	pnl.ColorMixer:SetColor( groupid and anus.Groups[ groupid ].color or color_white )
	
	pnl.body2 = pnl.ScrollPanel:Add( "anus_contentpanel" )
	pnl.body2:Dock( TOP )
	pnl.body2:DockMargin( 15, 4, 15, 4 )  
	pnl.body2:SetTall( 450 + 15 - 60 )
	pnl.body2.Think = function() end
	
	pnl.RankText = pnl.body2:Add( "DLabelEditable" )
	pnl.RankText:SetFont( "anus_SmallText" )
	pnl.RankText:SetText( "Rank Image" )
	pnl.RankText:SetTextColor( Color( 0, 0, 0, 255 ) )
	pnl.RankText:Dock( TOP )
	pnl.RankText:SetTextInset( 15, 0 )
	pnl.RankText:SizeToContents()
	
	pnl.RankImage = pnl.body2:Add( "DIconBrowser" )
	pnl.RankImage:Dock( FILL )
	pnl.RankImage:DockMargin( 15, 5, 15, 5 )
	pnl.RankImage.DefaultIcon = groupid and anus.Groups[ groupid ].icon or ""
	pnl.RankImage:SetSelectedIcon( groupid and anus.Groups[ groupid ].icon or "" )
	pnl.RankImage.OnChange = function( parent )
		if parent:GetSelectedIcon() != parent.DefaultIcon then
			base.Changes[ "Group" ][ "icon" ] = parent:GetSelectedIcon()
		else
			base.Changes[ "Group" ][ "icon" ] = nil
		end
	end
	
	::Finish::
	
	return base.Creations[ "Group" ]
end

function anusPrivilegesGroupEditor( base, groupid )
	base.Creations[ "Privileges" ] = base.content.body.grouptabs.ScrollPanel:Add( "DPanel" )
	
	local pnl = base.Creations[ "Privileges" ]
	
	pnl.ScrollPanel = pnl:Add( "DScrollPanel" )
	pnl.ScrollPanel:Dock( FILL )
	pnl.ScrollPanel:SetVerticalScrollbarEnabled( true )
	
	local SidebarHeaders = {}
	
	local SortedPlugins = table.GetKeys( anus.getPlugins() )
	table.sort( SortedPlugins, function( a, b )
		return tostring( a ) < tostring( b )
	end )
	
	local function CreateContents( category, cmd )
		SidebarHeaders[ category ] = pnl.ScrollPanel:Add( "DCollapsibleCategory" )
			
		local Cat = SidebarHeaders[ category ]
		Cat:SetLabel( category )
		Cat:SetExpanded( false )
		Cat:Dock( TOP )
		Cat.Header.DoClick = function( pnl )
			pnl:GetParent():Toggle()
				
			if Cat:GetParent().catOpened then
				if Cat:GetParent().catOpened == pnl then
					Cat:GetParent().catOpened = nil
					return
				else
					Cat:GetParent().catOpened:GetParent():Toggle()
					Cat.ListPanel.ListView:ClearSelection()
				end
			end
			Cat:GetParent().catOpened = pnl
		end
		Cat.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, 255 ) )
			if pnl:GetExpanded() then
				draw.RoundedBox( 0, 1, 1, w - 2, h - 2, Color( 215, 215, 215, 255 ) )
			else
				draw.RoundedBox( 0, 1, 1, w - 2, h - 2, Color( 255, 255, 255, 255 ) )
			end
		end
		Cat.Header:SetSize( 30, 40 )
		Cat.Header:SetFont( "anus_SmallText" )
		Cat.Header:SetTextColor(Color( 140, 140, 140, 255 )  ) 
			
		Cat.ListPanel = Cat:Add( "DPanel" )
		Cat.ListPanel:SetTall( 30 )
		Cat.ListPanel:Dock( TOP )
		Cat.ListPanel.Paint = function() end
			
		Cat.ListPanel.ListView = Cat.ListPanel:Add( "anus_listview" )
		Cat.ListPanel.ListView:SetHideHeaders( true )
		Cat.ListPanel.ListView:SetMultiSelect( false )
		Cat.ListPanel.ListView:DisableScrollbar( true )
		Cat.ListPanel.ListView:AddColumn( "Plugin" )
		Cat.ListPanel.ListView:AddColumn( "State" )
		Cat.ListPanel.ListView:SetTall( 30 )
		Cat.ListPanel.ListView:Dock( FILL )
		Cat.ListPanel.ListView.Columns[ 2 ]:SetFixedWidth( 45 )

		Cat.ListPanel.ListView.OnRowRightClick = function( pnl, index, pnlRow )
			local posx, posy = gui.MousePos() 
			local menu = vgui.Create( "DMenu" )
			menu:SetPos( posx, posy )
			menu:AddOption( "Edit (Advanced)", function()
			end )
			menu:AddSpacer()
			menu:AddOption( "Close" )
			menu.Think = function( pnl2 )
				if not IsValid( pnl ) then
					menu:Remove()
				end
			end
			menu:Open( posx, posy, true, pnl )
		end
		function Cat.ListPanel.ListView:DoDoubleClick( lineid, line )
			local Plugin = "allow"
			if line:GetColumnText( 2 ) == "icon16/accept.png" or line:GetColumnText( 2 ) == "icon16/plugin_edit.png" then
				Plugin = "deny"
			end
			line:SetColumnText( 2, Plugin == "allow" and "icon16/accept.png" or "icon16/cross.png" )
			LocalPlayer():ConCommand( "anus group" .. Plugin .. " " .. groupid .. " " .. line:GetColumnText( 1 ) )
		end
		
		
		local AccessPicture = "icon16/cross.png"
		if anus.getGroups()[ groupid ].Permissions[ cmd ] and isstring( anus.getGroups()[ groupid ].Permissions[ cmd ] ) then
			AccessPicture = "icon16/plugin_edit.png"
		elseif anus.getGroups()[ groupid ].Permissions[ cmd ] then
			AccessPicture = "icon16/accept.png"
		end
		local Line = Cat.ListPanel.ListView:AddLine( cmd, AccessPicture )
		Line:SetColumnIcon( 2 )
	end
	

	for i=1,#SortedPlugins do
		local k = SortedPlugins[ i ]
		local v = anus.getPlugin( k )

		if v.notRunnable then continue end

		v.category = v.category or "Unknown"
		
		if not SidebarHeaders[ v.category ] then	
			CreateContents( v.category, k )
		else
			local AccessPicture = "icon16/cross.png"
			if anus.getGroups()[ groupid ].Permissions[ k ] and isstring( anus.getGroups()[ groupid ].Permissions[ k ] ) then
				AccessPicture = "icon16/plugin_edit.png"
			elseif anus.getGroups()[ groupid ].Permissions[ k ] then
				AccessPicture = "icon16/accept.png"
			end
			local Line = SidebarHeaders[ v.category ].ListPanel.ListView:AddLine( k, AccessPicture )
			Line:SetColumnIcon( 2 )
			local Count = 30*#SidebarHeaders[ v.category ].ListPanel.ListView:GetLines() + 1
			SidebarHeaders[ v.category ].ListPanel:SetTall( Count )
			SidebarHeaders[ v.category ].ListPanel.ListView:SetTall( Count )
		end
	end
	
		-- add cvars that players in this group can change
	for k,v in next, anus.cvarsRegistered do
		if not SidebarHeaders[ "CVars" ] then
			CreateContents( "CVars", k )
		else
			local AccessPicture = "icon16/cross.png"
			if anus.getGroups()[ groupid ].Permissions[ k ] and isstring( anus.getGroups()[ groupid ].Permissions[ k ] ) then
				AccessPicture = "icon16/plugin_edit.png"
			elseif anus.getGroups()[ groupid ].Permissions[ k ] then
				AccessPicture = "icon16/accept.png"
			end
			local Line = SidebarHeaders[ "CVars" ].ListPanel.ListView:AddLine( k, AccessPicture )
			Line:SetColumnIcon( 2 )
			local Count = 30*#SidebarHeaders[ "CVars" ].ListPanel.ListView:GetLines()
			SidebarHeaders[ "CVars" ].ListPanel:SetTall( Count )
			SidebarHeaders[ "CVars" ].ListPanel.ListView:SetTall( Count )
		end
	end
	
	for k,v in next, anus.accessTags do
		if not SidebarHeaders[ "Access Tags" ] then
			CreateContents( "Access Tags", k )
		else
			local AccessPicture = "icon16/cross.png"
			if anus.getGroups()[ groupid ].Permissions[ k ] and isstring( anus.getGroups()[ groupid ].Permissions[ k ] ) then
				AccessPicture = "icon16/plugin_edit.png"
			elseif anus.getGroups()[ groupid ].Permissions[ k ] then
				AccessPicture = "icon16/accept.png"
			end
			local Line = SidebarHeaders[ "Access Tags" ].ListPanel.ListView:AddLine( k, AccessPicture )
			Line:SetColumnIcon( 2 )
			local Count = 30*#SidebarHeaders[ "Access Tags" ].ListPanel.ListView:GetLines()
			SidebarHeaders[ "Access Tags" ].ListPanel:SetTall( Count )
			SidebarHeaders[ "Access Tags" ].ListPanel.ListView:SetTall( Count )
		end
	end
	
	return base.Creations[ "Privileges" ]
end

function anusLimitsGroupEditor( base, groupid )

	base.Creations[ "Limits" ] = base.content.body.grouptabs.ScrollPanel:Add( "DPanel" ) --self.content.body.grouptabs.IconLayout:Add( "DPanel" ) --self.content.body.grouptabs.ScrollPanel:Add( "DPanel" )
	
	local pnl = base.Creations[ "Limits" ]
	
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
	base.SpawnLimits = {}
	local function RegisterNewSpawnLimit( header, convar, min, max )
		local NewHeader = header:gsub( " ", "_" ):lower()
		SpawnLimits[ NewHeader ] = { min = min or 0, max = max or 255 }
		base.SpawnLimits[ NewHeader ] = { custom = false }
		
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
		SpawnOverrideCheckBox:Dock( TOP )
		SpawnOverrideCheckBox:DockMargin( 50, 4, 50, 0 )
		if anus.groupSettings[ groupid ] and anus.groupSettings[ groupid ][ "Spawning" ][ NewHeader ] then
			SpawnOverrideCheckBox:SetValue( 1 )
			base.SpawnLimits[ NewHeader ].custom = true
		else
			SpawnOverrideCheckBox:SetValue( 0 )
		end
		SpawnOverrideCheckBox.OnChange = function( parent, val )
			if not val then
				SpawnHolderTbl[ NewHeader ].slider.Slider.OldSlideX = SpawnHolderTbl[ NewHeader ].slider.Slider:GetSlideX()
			end

			base.SpawnLimits[ NewHeader ].custom = val
			if val == true then
				base.SpawnLimits[ NewHeader ].limit = SpawnHolderTbl[ NewHeader ].slider.TextArea:GetText()
			end
		end

		SpawnHolderTbl[ NewHeader ].checkbox = SpawnOverrideCheckBox
		
		local SpawnSlider = SpawnBodyMaster:Add( "DNumSlider" )
		SpawnSlider:Dock( FILL )
		SpawnSlider:DockMargin( 15, 0, 15, 0 )
		SpawnSlider:SetMin( min or 0 )
		SpawnSlider:SetMax( max or 255 )
		SpawnSlider:SetValue( anus.groupSettings[ groupid ] and anus.groupSettings[ groupid ][ "Spawning" ][ NewHeader ] or GetConVarNumber( convar ) )
		SpawnSlider:SetDecimals( 0 )
		SpawnSlider.Label:Dock( NODOCK )
		SpawnSlider.Label:SetSize( 1, 1 )
		SpawnSlider.TextArea.DefaultText = SpawnSlider.TextArea:GetText()
		SpawnSlider.TextArea.OldOnValueChange = SpawnSlider.TextArea.OnValueChange
		SpawnSlider.TextArea.OnValueChange = function( parent, val, test )
			if SpawnBodyMaster.Disabled then
				parent:SetText( parent.DefaultText )
				return
			end

			base.SpawnLimits[ NewHeader ].limit = parent:GetText()
			parent.OldOnValueChange( parent, val )
		end
		SpawnSlider.OldOnValueChanged = SpawnSlider.OnValueChanged
		SpawnSlider.OnValueChanged = function( parent, val )
			if SpawnBodyMaster.Disabled then return end
			
			--base.SpawnLimits[ NewHeader ].limit = math.Round( val ) 
			parent.OldOnValueChanged( parent, val ) 
		end
		SpawnSlider.Scratch.OnValueChanged = function( parent )
			if SpawnBodyMaster.Disabled then return end

			base.SpawnLimits[ NewHeader ].limit = math.Round( parent:GetFloatValue() )
		end
		if SpawnOverrideCheckBox:GetChecked() then
			base.SpawnLimits[ NewHeader ].limit = SpawnSlider.TextArea:GetText()
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
	base.ToolRestrictions = {} 
	local function RegisterNewToolRestriction( header, itemname, toolname, b_on )
		BodySize = BodySize + 24 + Gap
		ToolHolderTbl[ itemname ] = { header = header, toggled = b_on }
		base.ToolRestrictions[ toolname ] = b_on and 1 or 0

		local FoundOld
		if anus.groupSettings[ groupid ] and anus.groupSettings[ groupid ][ "Tools" ][ toolname ] then
			base.ToolRestrictions[ toolname ] = anus.groupSettings[ groupid ][ "Tools" ][ toolname ]
			FoundOld = anus.groupSettings[ groupid ][ "Tools" ][ toolname ]
		end
		
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
		local image = "icon16/accept.png"
		if FoundOld != nil and FoundOld == 0 then
			image = "icon16/cancel.png"
		elseif FoundOld == nil and b_on == 0 then
			image = "icon16/cancel.png"
		end
		BodyImage:SetImage( image )
		BodyImage:SetSize( 16, 16 )
		BodyImage:Dock( RIGHT )
		BodyImage:DockMargin( 0, 3, 5, 3 )
		BodyImage.DoClick = function( parent )
			ToolHolderTbl[ itemname ].toggled = not ToolHolderTbl[ itemname ].toggled
			base.ToolRestrictions[ toolname ] = ToolHolderTbl[ itemname ].toggled and 1 or 0
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
	
	return base.Creations[ "Limits" ]
end


	-- Yes, this is inspired from ULX
	-- Allows easier transferring of code of ULX->ANUS
local AnusDefaultTeamModifiers =
{
	[ "Armor" ] = { default = 0, min = 0, max = 2^15-1 },
	[ "DuckSpeed" ] = { default = 0.15, min = 0, max = 5, decimals = 2 },
	[ "Gravity" ] = { default = 1, min = -1, max = 5, decimals = 2 },
	[ "Health" ] = { default = 100, min = 1, max = 2^31-1 },
	[ "JumpPower" ] = { default = 200, min = 0, max = 4000 },
	[ "MaxHealth" ] = { default = 100, min = 1, max = 2^31-1 },
	[ "Model" ] = "models/player/gman_high.mdl",
	[ "RunSpeed" ] = { default = 400, min = 5, max = 2500 },
	[ "StepSize" ] = { default = 18, min = 0, max = 512, decimals = 2 },
	[ "UnDuckSpeed" ] = { default = 0.1, min = 0, max = 5, decimals = 2 },
	[ "WalkSpeed" ] = { default = 200, min = 1, max = 2500 },
}
local AnusDefaultTeamModifiersSorted = {}
for k,v in next, AnusDefaultTeamModifiers do
	AnusDefaultTeamModifiersSorted[ #AnusDefaultTeamModifiersSorted + 1 ] = k
end
table.sort( AnusDefaultTeamModifiersSorted, function( a, b ) return a:lower() < b:lower() end )

function anusTeamsGroupEditor( base, groupid )
	base.Creations[ "Teams" ] = base.content.body.grouptabs.ScrollPanel:Add( "DPanel" ) --self.content.body.grouptabs.IconLayout:Add( "DPanel" ) --self.content.body.grouptabs.ScrollPanel:Add( "DPanel" )
	
	local pnl = base.Creations[ "Teams" ]
	base.TeamModifierStorage = {}
	
	local StartVisible = false
	
	pnl.ScrollPanel = pnl:Add( "DScrollPanel" )
	pnl.ScrollPanel:Dock( FILL )
	pnl.ScrollPanel:SetVerticalScrollbarEnabled( true )
	
	pnl.TeamName = pnl.ScrollPanel:Add( "DPanel" )
	pnl.TeamName:SetTall( 50 )
	pnl.TeamName:Dock( TOP )
	pnl.TeamName:DockMargin( 15, 5, 15, 0 )
	pnl.TeamName.Paint = function() end
	
	pnl.TeamName.Label = pnl.TeamName:Add( "DLabel" )
	pnl.TeamName.Label:SetFont( "anus_SmallText" )
	pnl.TeamName.Label:SetText( "Team:" )
	pnl.TeamName.Label:SetTextColor( Color( 0, 0, 0, 255 ) )
	pnl.TeamName.Label:Dock( LEFT )
	pnl.TeamName.Label:SizeToContents()
	
	pnl.TeamName.SelectInput = pnl.TeamName:Add( "DComboBoxEditable" )
	pnl.TeamName.SelectInput:Dock( FILL )
	pnl.TeamName.SelectInput:DockMargin( 15, 10, 15, 10 )
	pnl.TeamName.SelectInput:SetSortItems( false )
	local ChosenTeamIndex = 0
	for i=1,#anus.getTeams() do
		pnl.TeamName.SelectInput:AddChoice( anus.getTeams()[ i ].name )
		if anus.getTeams()[ i ].Groups[ groupid ] then
			ChosenTeamIndex = i
		end
	end
	pnl.TeamName.SelectInput:AddChoice( "<Remove A Team>" )
	pnl.TeamName.SelectInput.OnSelect = function( self, index, value )
		if not self.selected or value == "" then return end
	
		if value == "<Remove A Team>" then
			Derma_StringRequest( "Verification",
			"Enter the name of the team you wish to remove to continue.",
			"",
			function( txt ) LocalPlayer():ConCommand( "anus removeteam " .. txt ) end,
			function() end )
			
			return
		end
		pnl.TeamModifiers.ModifierList:SetVisible( true )
		pnl.TeamModifiers.ModifierList:GetLeft():Clear()--Selection()
		pnl.TeamModifiers.ModifierList:GetRight():Clear()--Selection()
		pnl.TeamModifiers.ModifierFuncs:Clear()
		
		pnl.TeamTable = anus.getTeams()[ self.selected ]
		timer.Create( "HackyUpdateFixSorts", pnl.TeamTable and 0 or 0.2, 1, function()
			if not IsValid( pnl ) then return end
			
			pnl.TeamModifiers.ModifierList:AddRightItem( "name" )
			pnl.TeamModifiers.ModifierList:AddRightItem( "color" )
			
			pnl.TeamTable = anus.getTeams()[ self.selected ]

			for k,v in ipairs( AnusDefaultTeamModifiersSorted ) do
				if pnl.TeamTable.Modifiers and pnl.TeamTable.Modifiers[ v ] then
					pnl.TeamModifiers.ModifierList:AddRightItem( v )
				else
					pnl.TeamModifiers.ModifierList:AddLeftItem( v )
				end
			end
		end )
	end
	pnl.TeamName.SelectInput.OnChange = function( self )
		local Found = false

		for k,txt in ipairs( self.Choices ) do
			if txt == self:GetText() and txt != "<Remove A Team>" then
				Found = true
			end
		end
	
		pnl.TeamModifiers.ModifierList:SetVisible( Found )
		pnl.TeamModifiers.ModifierFuncs:Clear()
	end
	
	pnl.TeamName.ApplyButton = pnl.TeamName:Add( "anus_button" )
	pnl.TeamName.ApplyButton:SetText( "Apply" )
	pnl.TeamName.ApplyButton:Dock( RIGHT )
	pnl.TeamName.ApplyButton:DockMargin( 0, 10, 0, 10 )
	pnl.TeamName.ApplyButton.DoClick = function( self )
		if pnl.TeamName.SelectInput:GetText() == "" then return end

		pnl.TeamModifiers.ModifierList:SetVisible( true )
		
		local Found = false
		for k,v in ipairs( anus.getTeams() ) do
			if v.name:lower() == pnl.TeamName.SelectInput:GetText():lower() then
				Found = true
				break
			end
		end
		if not Found then
			LocalPlayer():ConCommand( "anus_createteam " .. pnl.TeamName.SelectInput:GetText() )
			pnl.TeamName.SelectInput:AddChoice( pnl.TeamName.SelectInput:GetText(), nil, true, #pnl.TeamName.SelectInput.Choices )
		end
		
		base.TeamModifierStorage[ "TeamName" ] = pnl.TeamName.SelectInput:GetText()
		base.TeamModifierStorage[ "GroupID" ] = groupid
		if IsValid( pnl.ColorMixer ) then
			base.TeamModifierStorage[ "color" ] = pnl.ColorMixer:GetColor()
		elseif IsValid( pnl.NameText ) then
			base.TeamModifierStorage[ "name" ] = pnl.NameText:GetText()
		elseif IsValid( pnl.ModelSelect ) then
			base.TeamModifierStorage[ "Modifiers" ] = base.TeamModifierStorage[ "Modifiers" ] or {}
			base.TeamModifierStorage[ "Modifiers" ][ "Model" ] = pnl.ModelSelect.SelectedPanel:GetModelName() or "models/player/gman_high.mdl"
		elseif IsValid( pnl.SliderModifier ) then
			base.TeamModifierStorage[ "Modifiers" ] = base.TeamModifierStorage[ "Modifiers" ] or {}
			base.TeamModifierStorage[ "Modifiers" ][ pnl.SliderModifier.Label:GetText() ] = pnl.SliderModifier:GetValue()
		end
	end
	
	pnl.TeamModifiers = pnl.ScrollPanel:Add( "DPanel" )
		-- why not
	pnl.TeamModifiers:SetTall( 570 )
	pnl.TeamModifiers:Dock( FILL )
	pnl.TeamModifiers:DockMargin( 15, 0, 15, 0 )
	pnl.TeamModifiers.Paint = function( self, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 23, 255 ) )
	end
	
	pnl.TeamModifiers.ModifierList = pnl.TeamModifiers:Add( "DListBoxDivider" )
	pnl.TeamModifiers.ModifierList:SetVisible( StartVisible )
	pnl.TeamModifiers.ModifierList:SetLeftTitle( "Unused Modifiers" )
	pnl.TeamModifiers.ModifierList:SetRightTitle( "Used Modifiers" )
	pnl.TeamModifiers.ModifierList:SetTall( 150 )
	pnl.TeamModifiers.ModifierList:Dock( TOP )
	pnl.TeamModifiers.ModifierList:GetRight().OnSelect = function( self, item )
		if item:GetText() == "name" or item:GetText() == "color" then
			self:GetParent():GetMiddle().LeftButton:SetDisabled( true )
		else
			self:GetParent():GetMiddle().LeftButton:SetDisabled( false )
		end
		
		local SelectedValues = self:GetSelectedValues()
		if istable( SelectedValues ) then
			for k,v in ipairs( SelectedValues ) do
				if v == "name" or v == "color" then
					self:GetParent():GetMiddle().LeftButton:SetDisabled( true )
					break
				end
			end
		end
		
		pnl.TeamModifiers.ModifierFuncs:Clear()
		
		if istable( SelectedValues ) then return end

		local Modifier = AnusDefaultTeamModifiers[ item:GetText() ]
		
		if item:GetText() == "color" then
			pnl.TeamModifiers.ModifierFuncs:ShowColor( item:GetText(), pnl.TeamName.SelectInput.selected )
		elseif item:GetText() == "name" then
			pnl.TeamModifiers.ModifierFuncs:ShowTextEntry( item:GetText(), pnl.TeamName.SelectInput.selected )
		elseif item:GetText() == "Model" then
			pnl.TeamModifiers.ModifierFuncs:ShowModels( item:GetText(), pnl.TeamName.SelectInput.selected, Modifier )
		else
			pnl.TeamModifiers.ModifierFuncs:ShowSlider( item:GetText(), pnl.TeamName.SelectInput.selected, Modifier.default, Modifier.min, Modifier.max, Modifier.decimals )
		end
	end
	pnl.TeamModifiers.ModifierList.MovedToLeft = function( self, item )
		base.TeamModifierStorage[ item ] = ""
	end
	
	pnl.TeamModifiers.ModifierFuncs = pnl.TeamModifiers:Add( "DPanel" )
	pnl.TeamModifiers.ModifierFuncs:SetTall( 340 )
	pnl.TeamModifiers.ModifierFuncs:Dock( TOP )
	pnl.TeamModifiers.ModifierFuncs:DockMargin( 0, 10, 0, 0 )
	
	pnl.TeamModifiers.ModifierFuncs.ShowColor = function( self, item, id )
		pnl.ColorMixer = self:Add( "DColorMixer" )
		pnl.ColorMixer:Dock( FILL ) 
		pnl.ColorMixer:SetAlphaBar( false )
		pnl.ColorMixer.DefaultColor = anus.getTeams()[ id ].color
		pnl.ColorMixer:SetColor( anus.getTeams()[ id ].color )
	end
	pnl.TeamModifiers.ModifierFuncs.ShowTextEntry = function( self, item, id )
		pnl.NameText = self:Add( "DTextEntry" )
		pnl.NameText:SetTall( 20 )
		pnl.NameText:Dock( TOP )
		pnl.NameText:SetText( anus.getTeams()[ id ].name )
	end
	pnl.TeamModifiers.ModifierFuncs.ShowModels = function( self, item, id, default )
		pnl.ModelSelect = self:Add( "DModelSelect" )
		pnl.ModelSelect:Dock( FILL )
		local Output = {}
		for k,v in next, player_manager.AllValidModels() do
			Output[ v ] = k
		end
		pnl.ModelSelect:SetModelList( Output, nil, false, true )
		for k,v in ipairs( pnl.ModelSelect.Items ) do
			if anus.getTeams()[ id ].Modifiers[ "Model" ] and ( v.Model:lower() == anus.getTeams()[ id ].Modifiers[ "Model" ]:lower() ) then
				pnl.ModelSelect:SelectPanel( v )
				break
			elseif v.Model:lower() == default then
				pnl.ModelSelect:SelectPanel( v )
			end
		end
		--else
			
			-- pnl.ModelSelect.Items.Model
	end
	pnl.TeamModifiers.ModifierFuncs.ShowSlider = function( self, item, id, default, min, max, decimals )
		value = anus.getTeams()[ id ].Modifiers[ item ] or default
		
		pnl.SliderModifier = self:Add( "DNumSlider" )
		pnl.SliderModifier:SetTall( 20 )
		pnl.SliderModifier:Dock( TOP )
		pnl.SliderModifier:DockMargin( 60, 0, 20, 0 )
		pnl.SliderModifier:SetText( item or "N/A" )
		pnl.SliderModifier.Label:SetTextColor( Color( 0, 0, 0, 255 ) )
		pnl.SliderModifier:SetDecimals( decimals or 0 )
		pnl.SliderModifier:SetMin( min or 0 )
		pnl.SliderModifier:SetMax( max or 10 )
		pnl.SliderModifier:SetValue( value or min or 0 )
	end
	
	if ChosenTeamIndex != 0 then
		pnl.TeamName.SelectInput:ChooseOption( anus.getTeams()[ ChosenTeamIndex ].name, ChosenTeamIndex )
	end
	
	--pnl.TeamModifiers.ModifierFuncs:ShowColor()
	
	return base.Creations[ "Teams" ]
end
	
function anusMainGroupEditor( parent, groupid )
	local Base = vgui.Create( "EditablePanel" )
	Base:SetSize( anus.universalWidth( 640 ), anus.universalHeight( 760 ) )
	Base:Center()
	Base:MakePopup()
	Base.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, 255 ) ) 
		draw.RoundedBox( 0, 1, 1, w - 2, h - 2, color_white )
	end
	Base.PerformLayout = function( self, w, h )
		if not self.content.body.grouptabs.m_pActiveTab then return end

		local tabName = self.content.body.grouptabs.m_pActiveTab:GetText()
	end
	
	Base.Creations = {}
	Base.Changes = {}
	
	Base.content = Base:Add( "anus_contentpanel" )
	Base.content:SetTitle( "Group Editor: " .. (groupid and groupid or "New Group") )
	Base.content:Dock( FILL )
	Base.content.Think = function( pnl )
		for k,v in next, pnl:GetChildren() do
			v:DockMargin( 20, 40, 20, 0 )
		end
	end
	
	Base.content.body = Base.content:Add( "anus_contentpanel" )
	Base.content.body:Dock( FILL )
	Base.content.body.Think = function( pnl )
		for k,v in next, pnl:GetChildren() do
			v:DockMargin( 20, 0, 20, 0 )
		end
	end
	
	local body = Base.content.body
	
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
	body.grouptabs.ScrollPanel:Dock( FILL )
	body.grouptabs.ScrollPanel:SetVerticalScrollbarEnabled( true )

	LocalPlayer().GroupEditorsLatest = LocalPlayer().GroupEditorsLatest or {}
	LocalPlayer().GroupEditorsLatest[ Base ] = true
	
	body.grouptabs:AddSheet( "Group", anusBaseGroupEditor( Base, groupid ) )
	if groupid then
		body.grouptabs:AddSheet( "Privileges", anusPrivilegesGroupEditor( Base, groupid ) )
		body.grouptabs:AddSheet( "Limits", anusLimitsGroupEditor( Base, groupid ) )
		body.grouptabs:AddSheet( "Teams", anusTeamsGroupEditor( Base, groupid ) )
	end

	local old = body.grouptabs.SetActiveTab
	body.grouptabs.SetActiveTab = function( pnl, active )
		old( pnl, active )
		timer.Simple( 0, function()
			Base:InvalidateLayout( true )
		end )
	end
	

	
	body.BottomButtons = body:Add( "DPanel" )
	body.BottomButtons:Dock( BOTTOM )
	
	body.BottomButtons.DiscardButton = body.BottomButtons:Add( "anus_button" )
	body.BottomButtons.DiscardButton:SetText( "Discard and Close" )
	body.BottomButtons.DiscardButton:SetSize( 50, 50 )
	body.BottomButtons.DiscardButton:Dock( RIGHT )
	body.BottomButtons.DiscardButton:SizeToContents()
	body.BottomButtons.DiscardButton.DoClick = function( pnl2 )
		if not LocalPlayer().GroupEditorsLatest then return end
		
		if parent and IsValid( parent ) then
			parent.groupeditor = nil
		end

		for k,v in next, LocalPlayer().GroupEditorsLatest do
			k:Remove()
			LocalPlayer().GroupEditorsLatest[ k ] = nil
		end
	end
	
		
	body.BottomButtons.SaveButton = body.BottomButtons:Add( "anus_button" )
	body.BottomButtons.SaveButton:SetText( "Save" )
	body.BottomButtons.SaveButton:SetSize( 50, 50 )
	body.BottomButtons.SaveButton:Dock( RIGHT )
	body.BottomButtons.SaveButton:DockMargin( 0, 0, 15, 0 ) 
	body.BottomButtons.SaveButton:SizeToContents()
	body.BottomButtons.SaveButton.DoClick = function( pnl2 )
		
		if groupid then
			if Base.Changes[ "Group" ][ "name" ] then
				LocalPlayer():ConCommand( "anus renamegroup " .. groupid .. " " .. Base.Changes[ "Group" ][ "name" ] )
			end
			
			if Base.Changes[ "Group" ][ "color" ] then
				local ChangeColor = Base.Changes[ "Group" ][ "color" ]
				local NewColor = Color( ChangeColor.r, ChangeColor.g, ChangeColor.b )
				LocalPlayer():ConCommand( "anus changegroupcolor " .. groupid .. " " .. tostring( NewColor ) )
			end
			
			if Base.Changes[ "Group" ][ "icon" ] then
				LocalPlayer():ConCommand( "anus changegroupicon " .. groupid .. " " .. Base.Changes[ "Group" ][ "icon" ] )
			end
			
			if Base.Changes[ "Group" ][ "can_target" ] then
				LocalPlayer():ConCommand( "anus setgroupcantarget " .. groupid .. " " .. Base.Changes[ "Group" ][ "can_target" ] )
			end
			
			local CombineLimitsRestrictions = {}
			CombineLimitsRestrictions[ "Spawning" ] = Base.SpawnLimits
			CombineLimitsRestrictions[ "Tools" ] = Base.ToolRestrictions
			
			net.Start( "anus_sv_receivegroupsettings" )
				net.WriteString( groupid )
				net.WriteTable( CombineLimitsRestrictions )
			net.SendToServer()
			
			net.Start( "anus_sv_receiveteamsettings" )
				net.WriteTable( Base.TeamModifierStorage )
			net.SendToServer()
		else
			if not Base.Changes[ "Group" ][ "id" ] then return end
			
			LocalPlayer():ConCommand( "anus addgroup " .. Base.Changes[ "Group" ][ "id" ] .. " " .. Base.Changes[ "Group" ][ "inheritance" ] .. "" .. (Base.Changes[ "Group" ][ "name" ] and " " .. Base.Changes[ "Group" ][ "name" ] or "" ) )
		end
		
		parent.groupeditor = nil
		
		if not LocalPlayer().GroupEditorsLatest then return end
		for k,v in next, LocalPlayer().GroupEditorsLatest do
			k:Remove()
			LocalPlayer().GroupEditorsLatest[ k ] = nil
		end
	
	end
	
	hook.Add( "anus_GroupSettingsChanged", Base, function( prnt, group )
		if group == groupid then
			Derma_Query( "This group has been modified while you were in this window.", group .. " modified", "Close and Refresh", function() 
				if parent then
					parent.groupeditor = nil
				end

				for k,v in next, LocalPlayer().GroupEditorsLatest do
					k:Remove()
					LocalPlayer().GroupEditorsLatest[ k ] = nil
				end
			end, "Continue Editing", function() end )
		end
	end )
	
	return Base
end