local category = {}
	
	-- After 1000 bans, add option for next page.
	-- After about 1085 everything goes blank.
	
	-- add a search feature


	-- Optional: Player must be able to run this command to view this category
category.pluginid = "unban"
category.CategoryName = "Bans"

function category:Initialize( parent )
	
	parent.panel = parent:Add( "anus_contentpanel" )
	parent.panel:SetTitle( "Manage Bans" )
	parent.panel:Dock( FILL )
	
	parent.panel.topPanel = parent.panel:Add( "DPanel" )
	parent.panel.topPanel:SetTall( 20 )
	parent.panel.topPanel.Paint = function() end
	parent.panel.topPanel:Dock( TOP )

	parent.panel.topPanel.button = parent.panel.topPanel:Add( "anus_button" )
	parent.panel.topPanel.button:SetText( "Previous Page" )
	parent.panel.topPanel.button:SetTextColor( Color( 140, 140, 140, 255 ) )
	parent.panel.topPanel.button:SetFont( "anus_SmallText" )
	parent.panel.topPanel.button:SizeToContents()
	parent.panel.topPanel.button:SetDisabled( true )
	parent.panel.topPanel.button:Dock( LEFT )
	parent.panel.topPanel.button.Think = function( self )
		if parent.panel.listview and parent.panel.listview.CurrentPage == 1 then
			parent.panel.topPanel.button:SetDisabled( true )
		else
			parent.panel.topPanel.button:SetDisabled( false )
		end
	end
	parent.panel.topPanel.button.DoClick = function( self )
		parent.panel.listview:Clear()
		parent.panel.listview.CurrentPage = parent.panel.listview.CurrentPage - 1
		
		parent.panel.listview.CreatePage( parent.panel.listview.CurrentPage )
	end
	
	parent.panel.topPanel.button2 = parent.panel.topPanel:Add( "anus_button" )
	parent.panel.topPanel.button2:SetText( "Next Page" )
	parent.panel.topPanel.button2:SetTextColor( Color( 140, 140, 140, 255 ) )
	parent.panel.topPanel.button2:SetFont( "anus_SmallText" )
	parent.panel.topPanel.button2:SizeToContents()
	parent.panel.topPanel.button2:SetLeftOf( true )
	parent.panel.topPanel.button2:Dock( LEFT )
	parent.panel.topPanel.button2.Think = function( self )
		if parent.panel.listview and parent.panel.listview.CurrentPage == #banpages then
			parent.panel.topPanel.button2:SetDisabled( true )
		else
			parent.panel.topPanel.button2:SetDisabled( false )
		end
	end
	parent.panel.topPanel.button2.DoClick = function( self )
		parent.panel.listview:Clear()
		parent.panel.listview.CurrentPage = parent.panel.listview.CurrentPage + 1
		
		parent.panel.listview.CreatePage( parent.panel.listview.CurrentPage )
	end
	
	parent.panel.topPanel.searchentry = parent.panel.topPanel:Add( "DTextEntry" )
	parent.panel.topPanel.searchentry:SetText( "Search..." )
	parent.panel.topPanel.searchentry:SetWide( 150 )
	parent.panel.topPanel.searchentry:SetEditable( true )
	parent.panel.topPanel.searchentry:Dock( RIGHT )
	parent.panel.topPanel.searchentry.OnGetFocus = function( self )
		--parent:GetParent():SetKeyBoardInputEnabled( false )
		self:SetKeyboardInputEnabled( true )
		self.IsFocused = true
	end
	--[[	-- its not grabbing input, so hacks.
	keys = {}
	for i=48, 57 do
		if i == 48 then
			keys[ _G[ "KEY_0" ] ] = true
		elseif i == 57 then
			keys[ _G[ "KEY_9" ] ] = true
		else
			keys[ _G[ "KEY_" .. string.char( i ) ] ] = true
		end
	end
	for i=65, 90 do
		keys[ _G[ "KEY_" .. string.char( i ) ] ] = true
	end
	hook.Add( "CreateMove", parent.panel, function()
		if parent.panel.topPanel.searchentry.IsFocused then
			if ( LocalPlayer().searchcheck and LocalPlayer().searchcheck < CurTime() )  or not LocalPlayer().searchcheck then
				if input.IsKeyDown( KEY_BACKSPACE ) then
					
				for k,v in next, keys do
					if input.IsKeyDown( k ) then
						parent.panel.topPanel.searchentry

						LocalPlayer().searchcheck = CurTime() + 0.15
						break
					end
				end
			end
		end
	end )]]

	parent.panel.listview = parent.panel:Add( "anus_listview" )
	parent.panel.listview:SetMultiSelect( false )
	parent.panel.listview:AddColumn( "Name" )
	parent.panel.listview:AddColumn( "SteamID" )
	parent.panel.listview:AddColumn( "Unban Date" )
	parent.panel.listview:AddColumn( "Admin" )
	parent.panel.listview:AddColumn( "Reason" )
	parent.panel.listview:Dock( FILL )
	parent.panel.listview.Columns[ 1 ]:SetFixedWidth( 150 )
	
	parent.panel.listview.CurrentPage = 1
	
	local sortable = {}
	local count = 0
	local bans = table.Copy( anus.Bans )
	local totalbanned = 0
	/*local*/ banpages = {}
	for k,v in next, anus.Bans do
		totalbanned = totalbanned + 1
		count = count + 1
		
		if count > (#banpages * 500) then
			banpages[ #banpages + 1 ] = {}
			banpages[ #banpages ][ k ] = v
		else
			banpages[ #banpages ][ k ] = v
		end
	end
	if #banpages == 1 then
		parent.panel.topPanel.button:Remove()
		parent.panel.topPanel.button = nil
		
		parent.panel.topPanel.button2:Remove()
		parent.panel.topPanel.button2 = nil
	end
	
	function parent.panel.listview.CreatePage( page )
		count = 0
		for k,v in next, banpages[ parent.panel.listview.CurrentPage ] do
			count = count + 1

			timer.Create( "anus_addlines" .. count, (5*10^-3) * count, 1, function()
				if not parent or not parent.panel then return end
				if parent.panel.listview.CurrentPage != page then return end
				
				local time = v.time
				if time == 0 or time == "0" then
					time = "Never"
				else
					time = os.date( "%X - %d/%m/%Y", tonumber(time) )
				end
				
				local line = parent.panel.listview:AddLine( v.name, k, time, v.admin, v.reason:lower() )
				if time != "Never" then
					time = v.time
				end
				--sortable[ line ] = time
				sortable[ parent.panel.listview.CurrentPage ] = sortable[ parent.panel.listview.CurrentPage ] or {}
				sortable[ parent.panel.listview.CurrentPage ][ line ] = time
			end )
		end
		
		timer.Create( "anus_sortlines", table.Count( banpages[ parent.panel.listview.CurrentPage ] ) + (5*10^-3) + 0.1, 1, function()
			if not parent or not parent.panel then return end
			if parent.panel.listview.CurrentPage != page then return end

			for k,v in next, sortable[ parent.panel.listview.CurrentPage ] do
				if not k.SetSortValue then break end

				k:SetSortValue( 3,
					v
				)
			end
		end )
	end
	
	parent.panel.listview.CreatePage( 1 )
	
	
	parent.panel.listview:SortByColumn( 1, false )
	parent.panel.listview.OnRowRightClick = function( pnl, index, pnlRow )
		--DisableClipping( true )
		local posx, posy = gui.MousePos() 
		local menu = vgui.Create( "DMenu" )
		menu:SetPos( posx, posy )
		menu:AddOption( "Change Time", function()
			local column2 = parent.panel.listview:GetLine( parent.panel.listview:GetSelectedLine() ):GetColumnText( 2 )
			Derma_StringRequest(
				column2, 
				"Change ban time",
				anus.Bans[ column2 ][ "time" ] == "0" and anus.Bans[ column2 ][ "time" ] or anus.ConvertTimeToString( anus.Bans[ column2 ][ "time" ] - os.time(), true ),
				function( txt )
					net.Start( "anus_bans_edittime" )
						net.WriteString( column2 )
						net.WriteString( txt )
					net.SendToServer()
				end,
				function( txt )
				end
			)
		end )
		menu:AddOption( "Change Reason", function() 
			Derma_StringRequest( 
				parent.panel.listview:GetLine( parent.panel.listview:GetSelectedLine() ):GetColumnText( 2 ), 
				"Change ban reason",
				parent.panel.listview:GetLine( parent.panel.listview:GetSelectedLine() ):GetColumnText( 5 ),
				function( txt )
					net.Start( "anus_bans_editreason" )
						net.WriteString( parent.panel.listview:GetLine( parent.panel.listview:GetSelectedLine() ):GetColumnText( 2 ) )
						net.WriteString( txt )
					net.SendToServer()
				end,
				function( txt ) 
				end
			)
		end )
		menu:AddOption( "View Details" )
		menu:AddSpacer()
		menu:AddOption( "Visit Profile", function()
			gui.OpenURL( "http://steamcommunity.com/profiles/" .. util.SteamIDTo64( parent.panel.listview:GetLine( parent.panel.listview:GetSelectedLine() ):GetColumnText( 2 ) ) )
		end )
		menu:AddOption( "Close" )
		menu.Think = function( pnl2 )
			if not IsValid( pnl ) then
				menu:Remove()
			end
		end
		
		--DisableClipping( false )
	end
	
	parent.panel.bottomPanel = parent.panel:Add( "DPanel" )
	parent.panel.bottomPanel:SetTall( 20 )
	parent.panel.bottomPanel.Paint = function() end
	parent.panel.bottomPanel:Dock( BOTTOM )
	
	parent.panel.bottomPanel.totalbanned = parent.panel.bottomPanel:Add( "DLabel" )
	parent.panel.bottomPanel.totalbanned:SetText( "Total bans: " .. (totalbanned or 0) )--#parent.panel.listview:GetLines() )
	parent.panel.bottomPanel.totalbanned:SetTextColor( Color( 140, 140, 140, 255) )
	parent.panel.bottomPanel.totalbanned:SetFont( "anus_SmallText" )
	parent.panel.bottomPanel.totalbanned:SizeToContents()
	parent.panel.bottomPanel.totalbanned:Dock( LEFT )
	parent.panel.bottomPanel.totalbanned:DockMargin( 0, 0, 25, 0 )
	
	parent.panel.bottomPanel.pagenumber = parent.panel.bottomPanel:Add( "DLabel" )
	parent.panel.bottomPanel.pagenumber.page = parent.panel.listview.CurrentPage
	parent.panel.bottomPanel.pagenumber:SetText( "Page: " .. parent.panel.listview.CurrentPage .. " / " .. #banpages )
	parent.panel.bottomPanel.pagenumber:SetTextColor( Color( 140, 140, 140, 255) )
	parent.panel.bottomPanel.pagenumber:SetFont( "anus_SmallText" )
	parent.panel.bottomPanel.pagenumber:SizeToContents()
	parent.panel.bottomPanel.pagenumber:Dock( LEFT )
	parent.panel.bottomPanel.pagenumber.Think = function( self )
		if parent.panel.bottomPanel.pagenumber.page != parent.panel.listview.CurrentPage then
			self:SetText( "Page: " .. parent.panel.listview.CurrentPage .. " / " .. #banpages )
			self:SizeToContents()
			
			parent.panel.bottomPanel.pagenumber.page = parent.panel.listview.CurrentPage
		end
	end
	
	
	if LocalPlayer():HasAccess( "ban" ) then
		parent.panel.bottomPanel.buttonAddban = parent.panel.bottomPanel:Add( "anus_button" )
		parent.panel.bottomPanel.buttonAddban:SetText( "Add ban" )
		parent.panel.bottomPanel.buttonAddban:SetTextColor( Color( 140, 140, 140, 255 ) )
		parent.panel.bottomPanel.buttonAddban:SetFont( "anus_SmallText" )
		parent.panel.bottomPanel.buttonAddban:SizeToContents()
		parent.panel.bottomPanel.buttonAddban:Dock( RIGHT )
		parent.panel.bottomPanel.buttonAddban:SetLeftOf( true )
		parent.panel.bottomPanel.buttonAddban.DoClick = function( pnl )
			if not parent.panel.listview:GetSelectedLine() then return end
			LocalPlayer():ConCommand( "anus unban " .. parent.panel.listview:GetLine( parent.panel.listview:GetSelectedLine() ):GetColumnText( 2 ) )
		end
	end
	
		-- instead of unban selected
		-- unban steamid. 
		-- if a line is highlighted copy that into the new menu that pops up
		-- for cases of where theres a large amount of steams to sift through
	parent.panel.bottomPanel.buttonUnban = parent.panel.bottomPanel:Add( "anus_button" )
	parent.panel.bottomPanel.buttonUnban:SetText( "Unban Selected" )
	parent.panel.bottomPanel.buttonUnban:SetTextColor( Color( 140, 140, 140, 255 ) )
	parent.panel.bottomPanel.buttonUnban:SetFont( "anus_SmallText" )
	parent.panel.bottomPanel.buttonUnban:SizeToContents()
	parent.panel.bottomPanel.buttonUnban:Dock( RIGHT )
	parent.panel.bottomPanel.buttonUnban:SetLeftOf( true )
	parent.panel.bottomPanel.buttonUnban.DoClick = function( pnl )
		if not parent.panel.listview:GetSelectedLine() then return end
		LocalPlayer():ConCommand( "anus unban " .. parent.panel.listview:GetLine( parent.panel.listview:GetSelectedLine() ):GetColumnText( 2 ) )
		parent.panel.listview:RemoveLine( parent.panel.listview:GetSelectedLine() )
	end
	
end


anus.RegisterCategory( category )


