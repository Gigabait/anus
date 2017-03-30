local Category = {}
	
	-- After 1000 bans, add option for next page.
	-- After about 1085 everything goes blank.
	
	-- add a search feature


	-- Optional: Player must be able to run this command to view this Category
Category.pluginid = { "ban", "unban" }
Category.CategoryName = "Bans"

local BansPerPage = 160--200--240
	-- How many results show up in search
local SearchBanMax = 124

function Category:Initialize( parent )
		-- Stores everything
	self.panel = parent:Add( "anus_contentpanel" )
	self.panel:SetTitle( "Manage Bans" )
	self.panel:Dock( FILL )
	
		-- Creates the indentation, page handling, and search feature
	self.panel.topPanel = self.panel:Add( "DPanel" )
	self.panel.topPanel:SetTall( 20 )
	self.panel.topPanel.Paint = function() end
	self.panel.topPanel:Dock( TOP )
	
		-- Search results are displayed here
	self.panel.searchStorage = {}
		-- Ban pages are stored here
	self.panel.banPages = {}
		-- Currently searching
	self.panel.searchmode = false
		-- dont wory about it
	self.panel.totalbanned = 0
	self.panel.bancopies = {}
	self.panel.currentpage = 1
	
	self.panel.topPanel.PreviousPage = self.panel.topPanel:Add( "anus_button" )
	self.panel.topPanel.PreviousPage:SetText( "Previous Page" )
	self.panel.topPanel.PreviousPage:SetTextColor( Color( 140, 140, 140, 255 ) )
	self.panel.topPanel.PreviousPage:SetFont( "anus_SmallText" )
	self.panel.topPanel.PreviousPage:SizeToContents()
	self.panel.topPanel.PreviousPage:SetDisabled( true )
	self.panel.topPanel.PreviousPage:Dock( LEFT )
	self.panel.topPanel.PreviousPage.Think = function( pnl )
		if self.panel.currentpage == 1 then
			pnl:SetDisabled( true )
		else
			pnl:SetDisabled( false )
		end
	end
	self.panel.topPanel.PreviousPage.DoClick = function( pnl )
		self.panel.listview:Clear()
		self.panel.currentpage = self.panel.currentpage - 1
		
		self.panel.listview:ShowBanPage( self.panel.currentpage )
	end
	
	self.panel.topPanel.NextPage = self.panel.topPanel:Add( "anus_button" )
	self.panel.topPanel.NextPage:SetText( "Next Page" )
	self.panel.topPanel.NextPage:SetTextColor( Color( 140, 140, 140, 255 ) )
	self.panel.topPanel.NextPage:SetFont( "anus_SmallText" )
	self.panel.topPanel.NextPage:SizeToContents()
	self.panel.topPanel.NextPage:SetLeftOf( true )
	self.panel.topPanel.NextPage:Dock( LEFT )
	self.panel.topPanel.NextPage.Think = function( pnl )
		if self.panel.currentpage == #self.panel.banPages then
			pnl:SetDisabled( true )
		else
			pnl:SetDisabled( false )
		end
	end
	self.panel.topPanel.NextPage.DoClick = function( pnl )
		self.panel.listview:Clear()
		self.panel.currentpage = self.panel.currentpage + 1
		
		self.panel.listview:ShowBanPage( self.panel.currentpage )
	end
	
		-- Error msg
	self.panel.topPanel.NarrowResultsText = self.panel.topPanel:Add( "DLabel" )
	self.panel.topPanel.NarrowResultsText:SetFont( "anus_SmallTitle" )
	self.panel.topPanel.NarrowResultsText:SetText( "Please narrow your results!" )
	self.panel.topPanel.NarrowResultsText:SetTextColor( Color( 240, 25, 25, 0 ) )
	self.panel.topPanel.NarrowResultsText:Dock( LEFT )
	self.panel.topPanel.NarrowResultsText:DockMargin( 15, 0, 0, 0 )
	self.panel.topPanel.NarrowResultsText:SizeToContents()
	self.panel.topPanel.NarrowResultsText.Think = function( pnl )
		local Col = pnl:GetTextColor()
			
		pnl:SetTextColor( Color( Col.r, Col.g, Col.b, self.panel.searchoverflow and 255 or 0 ) )
	end
		
		
	
		-- Search function
	self.panel.topPanel.searchentry = self.panel.topPanel:Add( "DTextEntry" )
	self.panel.topPanel.searchentry:SetText( "Search..." )
	self.panel.topPanel.searchentry:SetWide( 150 )
	self.panel.topPanel.searchentry:SetEditable( true )
	self.panel.topPanel.searchentry:Dock( RIGHT )
	self.panel.topPanel.searchentry.OnChange = function( pnl )
		self.panel.listview:ShowBanPage( "search" )
	end
	
	
	
		-- Base list
	self.panel.listview = self.panel:Add( "anus_listview" )
	self.panel.listview:SetMultiSelect( false )
	self.panel.listview:AddColumn( "Name" )
	self.panel.listview:AddColumn( "SteamID" )
	self.panel.listview:AddColumn( "Unban Date" )
	self.panel.listview:AddColumn( "Admin" )
	self.panel.listview:AddColumn( "Reason" )
	self.panel.listview:Dock( FILL )
	self.panel.listview:DockMargin( 60, 0, 0, 60 )
	self.panel.listview.Columns[ 1 ]:SetFixedWidth( 150 )
	
		-- These should be self explanatory
	function self.panel.listview:CreateBanPage()
		local BanCount = 0
		
		self:GetParent().banPages[ #self:GetParent().banPages + 1 ] = {}
		
		return #self:GetParent().banPages
	end
	function self.panel.listview:GetMaxBanPages()
		return #self:GetParent().banPages
	end
	function self.panel.listview:AddBanToPage( page, steamid, tbl )
		self:GetParent().banPages[ page ][ #self:GetParent().banPages[ page ] + 1 ] = { steamid = steamid, tbl = tbl }
	end
	function self.panel.listview:RemoveAllBanPages()
		self:GetParent().banPages = {}
		self:GetParent().currentpage = 1
	end
	function self.panel.listview:ShowBanPage( page_or_search )
		self:Clear()
		
			-- page number
		if isnumber( page_or_search ) then
			self:GetParent().searchoverflow = false
			if self:GetParent().searchmode then self:GetParent().topPanel.searchentry:SetText( "Search..." ) self:GetParent().searchmode = false end
			
			for k,v in ipairs( ( self:GetParent().banPages and self:GetParent().banPages[ page_or_search ] ) or {} ) do
				
				local time = v.tbl.unbandate
				if time == 0 or time == "0" then
					time = "Never"
				else
					time = os.date( "%X - %d/%m/%Y", tonumber( time ) )
				end
				
				local line = self:AddLine( v.tbl.name, v.steamid, time, v.tbl.admin, v.tbl.reason )
				line.OldTime = v.tbl.unbandate
				if time != "Never" then
					time = v.unbandate
				end
			end
			-- search
		else
			self:GetParent().searchmode = true
			local SearchText = self:GetParent().topPanel.searchentry:GetText()
			
			local SearchCount = 0
			for k,v in next, self:GetParent().bancopies do
				if SearchCount >= SearchBanMax then 
					self:GetParent().searchoverflow = true 
					break
				else
					self:GetParent().searchoverflow = false
				end
					-- Searches steamid, banned name, and admin steamid
				if not k:lower():find( SearchText:lower() ) and not
				v.name:lower():find( SearchText:lower() ) and not 
				v.admin_steamid:lower():find( SearchText:lower() ) then continue end
				
				local time = v.unbandate
				if time == 0 or time == "0" then
					time = "Never"
				else
					time = os.date( "%X - %d/%m/%Y", tonumber( time ) )
				end
				
				local line = self:AddLine( v.name, k, time, v.admin, v.reason )
				line.OldTime = v.unbandate
				if time != "Never" then
					time = v.unbandate
				end
				
				SearchCount = SearchCount + 1
			end
		end	

		local PageText = "Page: 0/0"
		if not self:GetParent().searchmode then
			PageText = "Page: " .. self:GetParent().currentpage .. "/" .. #self:GetParent().banPages
		end
		self:GetParent().bottomPanel.pagenumber:SetText( PageText )
		self:GetParent().bottomPanel.pagenumber:SizeToContents()		
	end
	
	self.panel.listview.OnRowRightClick = function( pnl, index, row )
		local MPosX, MPosY = gui.MousePos() 
		local DMenu = vgui.Create( "DMenu" )
		DMenu:SetPos( MPosX, MPosY )
		if row.IsUnbanned then
			DMenu:AddOption( "Revert Unban", function()
				local Column2 = row:GetColumnText( 2 )
				local Time = row.OldTime != 0 and row.OldTime != "0" and (row.OldTime - os.time()) or 0
				LocalPlayer():ConCommand( "anus banid " .. Column2 .. " " .. Time .. " " .. row:GetColumnText( 5 ) )
			end )
		else
			DMenu:AddOption( "Change Time", function()
				local Column2 = row:GetColumnText( 2 )
				Derma_StringRequest(
					Column2, 
					"Change ban time",
					anus.Bans[ Column2 ].unbandate == "0" and anus.Bans[ Column2 ].unbandate or anus.convertTimeToString( anus.Bans[ Column2 ].unbandate - os.time(), true ),
					function( txt )
						LocalPlayer():ConCommand( "anus banid " .. Column2 .. " " .. txt .. " " .. row:GetColumnText( 5 ) )
					end,
					function( txt )
					end
				)
			end )
			DMenu:AddOption( "Change Reason", function()
				Derma_StringRequest( 
					row:GetColumnText( 2 ), 
					"Change ban reason",
					row:GetColumnText( 5 ),
					function( txt )
						local Time = row.OldTime != 0 and row.OldTime != "0" and (row.OldTime - os.time()) or 0
						LocalPlayer():ConCommand( "anus banid " .. row:GetColumnText( 2 ) .. " " .. Time .. " " .. txt )
					end,
					function( txt ) 
					end
				)
			end )
			DMenu:AddOption( "View Details" )
			DMenu:AddOption( "View Ban History", function()
				LocalPlayer():ConCommand( "anus banhistoryid " .. row:GetColumnText( 2 ) )
			end )
		end
		DMenu:AddSpacer()
		DMenu:AddOption( "Visit Profile", function()
			gui.OpenURL( "http://steamcommunity.com/profiles/" .. util.SteamIDTo64( row:GetColumnText( 2 ) ) )
		end )
		DMenu:AddOption( "Close" )
		DMenu.Think = function( pnl2 )
			if not IsValid( pnl ) or not anus_mainMenu or not anus_mainMenu:IsVisible() then
				DMenu:Remove()
			end
		end
		DMenu:Open( MPosX, MPosY, true, pnl )
	end
	
	self.panel.bottomPanel = self.panel:Add( "DPanel" )
	self.panel.bottomPanel:SetTall( 20 )
	self.panel.bottomPanel.Paint = function() end
	self.panel.bottomPanel:Dock( BOTTOM )
	
	self.panel.bottomPanel.totalbanned = self.panel.bottomPanel:Add( "DLabel" )
	self.panel.bottomPanel.totalbanned:SetText( "Total bans: " .. (totalbanned or 0) )
	self.panel.bottomPanel.totalbanned:SetTextColor( Color( 140, 140, 140, 255) )
	self.panel.bottomPanel.totalbanned:SetFont( "anus_SmallText" )
	self.panel.bottomPanel.totalbanned:SizeToContents()
	self.panel.bottomPanel.totalbanned:Dock( LEFT )
	self.panel.bottomPanel.totalbanned:DockMargin( 0, 0, 25, 0 )
	
	self.panel.bottomPanel.pagenumber = self.panel.bottomPanel:Add( "DLabel" )
	self.panel.bottomPanel.pagenumber:SetText( "Page: " .. "0/0" )
	self.panel.bottomPanel.pagenumber:SetTextColor( Color( 140, 140, 140, 255) )
	self.panel.bottomPanel.pagenumber:SetFont( "anus_SmallText" )
	self.panel.bottomPanel.pagenumber:SizeToContents()
	self.panel.bottomPanel.pagenumber:Dock( LEFT )

	if LocalPlayer():hasAccess( "ban" ) then
		self.panel.bottomPanel.buttonAddban = self.panel.bottomPanel:Add( "anus_button" )
		self.panel.bottomPanel.buttonAddban:SetText( "Add ban" )
		self.panel.bottomPanel.buttonAddban:SetTextColor( Color( 140, 140, 140, 255 ) )
		self.panel.bottomPanel.buttonAddban:SetFont( "anus_SmallText" )
		self.panel.bottomPanel.buttonAddban:SizeToContents()
		self.panel.bottomPanel.buttonAddban:Dock( RIGHT )
		self.panel.bottomPanel.buttonAddban:SetLeftOf( true )
		self.panel.bottomPanel.buttonAddban.DoClick = function( pnl )
			vgui.Create( "anus_addban" ) 
		end
	end

	self.panel.bottomPanel.buttonUnban = self.panel.bottomPanel:Add( "anus_button" )
	self.panel.bottomPanel.buttonUnban:SetText( "Unban Selected" )
	self.panel.bottomPanel.buttonUnban:SetTextColor( Color( 140, 140, 140, 255 ) )
	self.panel.bottomPanel.buttonUnban:SetFont( "anus_SmallText" )
	self.panel.bottomPanel.buttonUnban:SizeToContents()
	self.panel.bottomPanel.buttonUnban:Dock( RIGHT )
	self.panel.bottomPanel.buttonUnban:SetLeftOf( true )
	self.panel.bottomPanel.buttonUnban.DoClick = function( pnl )
		if not self.panel.listview:GetSelectedLine() then return end
		LocalPlayer():ConCommand( "anus unban " .. self.panel.listview:GetLine( self.panel.listview:GetSelectedLine() ):GetColumnText( 2 ) )
	end

	self.panel.bottomPanel.buttonRefresh = self.panel.bottomPanel:Add( "anus_button" )
	self.panel.bottomPanel.buttonRefresh:SetText( "Refresh Bans" )
	self.panel.bottomPanel.buttonRefresh:SetTextColor( Color( 140, 140, 140, 255 ) )
	self.panel.bottomPanel.buttonRefresh:SetFont( "anus_SmallText" )
	self.panel.bottomPanel.buttonRefresh:SizeToContents()
	self.panel.bottomPanel.buttonRefresh:Dock( RIGHT )
	self.panel.bottomPanel.buttonRefresh:SetLeftOf( true )
	self.panel.bottomPanel.buttonRefresh.DoClick = function( pnl )
		net.Start( "anus_ban_requestbans" )
		net.SendToServer()
	end
	
	self:Refresh( self )
	
	hook.Add( "OnBanlistChanged", self.panel, function( pnl, bantype, steamid )
		if not bantype then
			self:Refresh( self )
			return
		end
		
		local LineToUse = nil
		for k,v in ipairs( self.panel.listview:GetLines() ) do
			if v:GetColumnText( 2 ) == steamid then
				if bantype == 1 then
					v.customPaint = nil
				else
					v.customPaint = Color( 215, 35, 35, 255 )
				end
				v.IsUnbanned = bantype == 2
				LineToUse = v
			end
			
			if v == LineToUse and not v.IsUnbanned then
				local columns =
				{
				"name",
				"k",
				"time",
				"admin",
				"reason",
				}

				local ColumnText = nil
				for a,b in next, v.Columns do
					ColumnText = v:GetColumnText( a )
					if a == 2 then continue end
					if a == 3 then
						ColumnText = v.OldTime
						if ColumnText != anus.Bans[ steamid ][ columns[ a ] ] then
							local TimeNew = anus.Bans[ steamid ][ columns[ a ] ]
							print( "AYE TIMENEW", timenew )
							v.OldTime = TimeNew
							if TimeNew == 0 or TimeNew == "0" then
								TimeNew = "Never"
							else
								TimeNew = os.date( "%X - %d/%m/%Y", tonumber( TimeNew ) )
							end
							
							v:SetColumnText( a, TimeNew )
						end
					else
						if ColumnText != anus.Bans[ steamid ][ columns[ a ] ] then
							v:SetColumnText( a, anus.Bans[ steamid ][ columns[ a ] ] )
						end
					end
				end
			end
		end
		
		for k,v in next, self.panel.banPages do
			if k == steamid then
				if bantype == 1 then
					v.customPaint = nil
				else
					v.customPaint = Color( 215, 35, 35, 255 )
				end
				v.IsUnbanned = bantype == 2
			end
		end
		-- make the items red when ban removed
	end )
end

function Category:Refresh( parent )
	parent.panel.topPanel.searchentry:SetText( "Search..." )
	parent.panel.listview:Clear()
	parent.panel.listview:RemoveAllBanPages()
	
	parent.panel.bancopies = table.Copy( anus.Bans )
	local Sortable = {}
	local Output = {}
	for k,v in next, parent.panel.bancopies do
		local SteamGrabber = tonumber( string.sub( k, 11, #k ) )
		
		Sortable[ #Sortable + 1 ] = { simplified = SteamGrabber or k, steamid = k }
	end

	table.sort( Sortable, function( a, b ) 
		if isstring( a.simplified ) then
			return true
		elseif isstring( b.simplified ) then
			return false
		end

		return a.simplified < b.simplified 
	end )
	
	--PrintTable( Sortable )
	
	
	parent.panel.totalbanned = #Sortable
	local BanCount = 0
	for k,v in next, Sortable do
		if BanCount % BansPerPage == 0 then
			local Page = parent.panel.listview:CreateBanPage()
			parent.panel.listview:AddBanToPage( Page, v.steamid, parent.panel.bancopies[ v.steamid ] )
		else
			local CurrentPage = parent.panel.listview:GetMaxBanPages()
			parent.panel.listview:AddBanToPage( CurrentPage, v.steamid, parent.panel.bancopies[ v.steamid ] )
		end

		BanCount = BanCount + 1
	end
	
	parent.panel.bottomPanel.totalbanned:SetText( "Total bans: " .. (parent.panel.totalbanned or 0) )
	parent.panel.bottomPanel.totalbanned:SizeToContents()
	
	parent.panel.listview:ShowBanPage( 1 )
end

anus.registerCategory( Category )


local panel = {}

function panel:Init()
	self:SetSize( 500, 300 )
	self:Center()
	self:MakePopup()
	
	self.panel = self:Add( "anus_contentpanel" )
	self.panel:SetTitle( "Add Ban" )
	self.panel:Dock( FILL )
	
	self.panel.Form = self.panel:Add( "DForm" )
	self.panel.Form:SetName( "" )
	self.panel.Form:SetAutoSize( true )
	self.panel.Form:Dock( FILL )
	self.panel.Form:SetWide( 60 )
	self.panel.Form.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, 255 ) )
		draw.RoundedBox( 0, 1, 1, w - 2, h - 2, color_white )
	end
	self.panel.Form.Header:SetTall( 1 )
	
	self.panel.Form.ComboBoxEditable = function( pnl, strLabel, strConVar )
		local left = vgui.Create( "DLabel", pnl )
		left:SetText( strLabel )
		left:SetDark( true )

		local right = vgui.Create( "DComboBoxEditable", pnl )
		right:SetConVar( strConVar )
		right:Dock( FILL )
		function right:OnSelect( index, value, data )
			if ( !pnl.m_strConVar ) then return end
			RunConsoleCommand( pnl.m_strConVar, tostring( data or value ) )
		end

		pnl:AddItem( left, right )

		return right, left
	end
	
	self.panel.Form.Identity = self.panel.Form:ComboBoxEditable( "Name/SteamID", "a" )
	self.panel.Form.Identity.GetAutoComplete = function( pnl, txt )
		local Output = {}
		local Name = anus.findPlayer( txt, nil, LocalPlayer() )
		
		if Name and not istable( Name ) then
			Output[ #Output + 1 ] = Name:Nick()
		elseif Name then
			for k,v in ipairs( Name ) do
				Output[ #Output + 1 ] = v:Nick()
			end
		end
		
		local Steam, Matching = anus.findPlayer( txt, "steam", LocalPlayer() )
		
		if Steam and not istable( Steam ) and Matching != "*" and Matching != "@" and Matching != "^" then
			Output[ #Output + 1 ] = Steam:Nick()
		elseif Steam and Matching != "*" and Matching != "@" and Matching != "^" then
			for k,v in ipairs( Steam ) do
				Output[ #Output + 1 ] = v:Nick()
			end
		end

		return Output
	end
		-- default autocomplete is broken.
		-- due to losing focus
	self.panel.Form.Identity.OpenAutoComplete = function( pnl, tab )

		if ( !tab ) then return end
		if ( #tab == 0 ) then return end

		pnl.Menu = DermaMenu()
		pnl.Menu:SetParent( pnl )

		for k, v in pairs( tab ) do

			pnl.Menu:AddOption( v, function() pnl:SetText( v ) pnl:SetCaretPos( v:len() ) pnl:RequestFocus() end )

		end

		local x, y = pnl:LocalToScreen( 0, pnl:GetTall() )
		pnl.Menu:SetMinimumWidth( pnl:GetWide() )
		pnl.Menu:Open( x, y, true, pnl ) 
		pnl.Menu:SetPos( x, y )
		pnl.Menu:SetMaxHeight( ( ScrH() - y ) - 10 )

	end
	for k,v in ipairs( player.GetAll() ) do
		self.panel.Form.Identity:AddChoice( v:Nick() )
	end
	self.panel.Form:AddItem( self.panel.Form.Identity )
	
	
	
	local BanTimes = {
		{ "1 Hour", ANUS_HOUR },
		{ "1 Day", ANUS_DAY },
		{ "3 Days", ANUS_DAY*3 },
		{ "1 Week", ANUS_WEEK },
		{ "1 Month", ANUS_MONTH },
		{ "Permanent", 0 }
	}
	
	--PrintTable( BanTimes )
	
	self.panel.Form.BanLength = self.panel.Form:ComboBox( "Ban Length" )
	self.panel.Form.BanLength:SetSortItems( false )
	for k,v in ipairs( BanTimes ) do
		self.panel.Form.BanLength:AddChoice( v[ 1 ] )
	end
	self.panel.Form:AddItem( self.panel.Form.BanLength )
	
	local BanReasons = {
		"Rule Breaker",
		"Spammer",
		"Troll",
		"Bad Language",
	}
	
	self.panel.Form.BanReason = self.panel.Form:ComboBoxEditable( "Ban Reason" )
	for k,v in ipairs( BanReasons ) do
		self.panel.Form.BanReason:AddChoice( v )
	end
	self.panel.Form:AddItem( self.panel.Form.BanReason )
	self.panel.Form.BanReason:GetParent():DockPadding( 10, 10, 10, 10 )
	
	self.panel.BottomPanel = self.panel:Add( "DPanel" )
	self.panel.BottomPanel:Dock( BOTTOM )
	self.panel.BottomPanel.Paint = function() end
	
	self.panel.Cancel = self.panel.BottomPanel:Add( "anus_button" )
	self.panel.Cancel:SetText( "Cancel" )
	self.panel.Cancel:SetTextColor( Color( 140, 140, 140, 255 ) )
	self.panel.Cancel:SetFont( "anus_SmallText" )
	self.panel.Cancel:SizeToContents()
	self.panel.Cancel:Dock( RIGHT )
	self.panel.Cancel:DockMargin( 15, 0, 0, 0 )
	self.panel.Cancel.DoClick = function( pnl )
		self:Remove()
	end
	
	self.panel.Accept = self.panel.BottomPanel:Add( "anus_button" )
	self.panel.Accept:SetText( "Accept" )
	self.panel.Accept:SetTextColor( Color( 140, 140, 140, 255 ) )
	self.panel.Accept:SetFont( "anus_SmallText" )
	self.panel.Accept:SizeToContents()
	self.panel.Accept:Dock( RIGHT ) 
	self.panel.Accept.DoClick = function( pnl )
		if #self.panel.Form.Identity:GetText() == 0 then return end
		
		local BanType = "ban"
		
		if string.IsSteamID( self.panel.Form.Identity:GetText() ) then
			BanType = "banid"
		end
		
		local BanLength = 0
		
		if #self.panel.Form.BanLength:GetText() > 0 and string.find( self.panel.Form.BanLength:GetText(), " " ) then
			for k,v in ipairs( BanTimes ) do
				if v[ 1 ] == self.panel.Form.BanLength:GetText() then
					BanLength = v[ 2 ]
					break
				end
			end
		elseif #self.panel.Form.BanLength:GetText() > 0 then
			BanLength = self.panel.Form.BanLength:GetText()
		end

		LocalPlayer():ConCommand( "anus " .. BanType .. " " .. self.panel.Form.Identity:GetText() .. " " .. BanLength .. " " .. ( #self.panel.Form.BanReason:GetText() > 0 and self.panel.Form.BanReason:GetText() or "No reason given." ) )
	end
end

function panel:SetTitle( strTitle )
	self.strTitle = strTitle

	self.Title = self:Add( "DLabel" )
	self.Title:SetText( strTitle )
	self.Title:SetTextColor( Color( 140, 140, 140, 255 ) )
	self.Title:SetFont( "anus_MediumTitle" )
	self.Title:SetPos( 20, 20 )
	self.Title:SizeToContents()
end

function panel:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, 255 ) )
	draw.RoundedBox( 0, 1, 1, w - 2, h - 2, color_white )
end

function panel:Think()
end

vgui.Register( "anus_addban", panel, "EditablePanel" )
