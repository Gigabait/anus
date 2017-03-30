local Category = {}

	-- Optional: Player must be able to run this command to view this Category
Category.pluginid = { "map", "votemap", "votemap2" }
Category.CategoryName = "Maps"

function Category:Initialize( parent )
	
	self.panel = parent:Add( "anus_contentpanel" )
	self.panel:SetTitle( "Maps" )
	self.panel:Dock( FILL )
	
	self.panel.listview = self.panel:Add( "anus_listview" )
	self.panel.listview:SetMultiSelect( false )
	self.panel.listview:AddColumn( "Name" )
	self.panel.listview:AddColumn( "Popularity" )
	self.panel.listview:Dock( FILL )
	self.panel.listview:SetMultiSelect( true )
	
	for k,v in next, anus_maps or {} do
		self.panel.listview:AddLine( k, v .. "%" )
	end

	if not LocalPlayer().RequestedMaps and anus_maps == nil then
		net.Start( "anus_requestmaps" )
		net.SendToServer()
		
		LocalPlayer().RequestedMaps = true
		
		local MPanelTxt = parent:GetParent().CategoryLastClicked:GetText()
		timer.Create( "anus_mappanel_refresh", 0.2, 1, function()
			parent:GetParent().CategoryList[ MPanelTxt ]:DoClick()
		end )
	end
	for k,v in ipairs( self.panel.listview:GetLines() ) do
		local FixedSort = v:GetValue( 2 ):gsub( "%%", "" )
		v:SetSortValue( 2, tonumber( FixedSort ) )
	end
	self.panel.listview:SortByColumn( 2, true )

	self.panel.bottomPanel = self.panel:Add( "DPanel" )
	self.panel.bottomPanel:SetTall( 20 )
	self.panel.bottomPanel.Paint = function() end
	self.panel.bottomPanel:Dock( BOTTOM )
	
	self.panel.bottomPanel.totalbanned = self.panel.bottomPanel:Add( "DLabel" )
	self.panel.bottomPanel.totalbanned:SetText( "Total maps: " .. #self.panel.listview:GetLines() )
	self.panel.bottomPanel.totalbanned:SetTextColor( Color( 140, 140, 140, 255) )
	self.panel.bottomPanel.totalbanned:SetFont( "anus_SmallText" )
	self.panel.bottomPanel.totalbanned:SizeToContents()
	self.panel.bottomPanel.totalbanned:Dock( LEFT )
	
	
	if LocalPlayer():hasAccess( "votemap" ) and not anus.isPluginDisabled( "votemap" ) then
		self.panel.bottomPanel.buttonVoteMap = self.panel.bottomPanel:Add( "anus_button" )
		self.panel.bottomPanel.buttonVoteMap:SetText( "Start Vote" )
		self.panel.bottomPanel.buttonVoteMap:SetTextColor( Color( 140, 140, 140, 255 ) )
		self.panel.bottomPanel.buttonVoteMap:SetFont( "anus_SmallText" )
		self.panel.bottomPanel.buttonVoteMap:SizeToContents()
		self.panel.bottomPanel.buttonVoteMap:Dock( RIGHT )
		self.panel.bottomPanel.buttonVoteMap:SetLeftOf( true )
		self.panel.bottomPanel.buttonVoteMap.DoClick = function( pnl )
			if not self.panel.listview:GetSelectedLine() then return end
			local Str = ""
			for k,v in next, self.panel.listview:GetSelected() do
				if k == #self.panel.listview:GetSelected() and k == 1 then
					LocalPlayer():ConCommand( "anus votemap2 15 " .. v:GetColumnText( 1 ) )
					return
				elseif k == #self.panel.listview:GetSelected() then
					Str = Str .. v:GetColumnText( 1 )
				else
					Str = Str .. v:GetColumnText( 1 ) .. " "
				end
			end
			LocalPlayer():ConCommand( "anus votemap 15 " .. Str )
		end
	end

	if LocalPlayer():hasAccess( "map" ) then
		self.panel.bottomPanel.buttonChangeMap = self.panel.bottomPanel:Add( "anus_button" )
		self.panel.bottomPanel.buttonChangeMap:SetText( "Force Map Change" )
		self.panel.bottomPanel.buttonChangeMap:SetTextColor( Color( 140, 140, 140, 255 ) )
		self.panel.bottomPanel.buttonChangeMap:SetFont( "anus_SmallText" )
		self.panel.bottomPanel.buttonChangeMap:SizeToContents()
		self.panel.bottomPanel.buttonChangeMap:Dock( RIGHT )
		self.panel.bottomPanel.buttonChangeMap:SetLeftOf( true )
		self.panel.bottomPanel.buttonChangeMap.DoClick = function( pnl )
			if #self.panel.listview:GetSelected() > 1 then
				LocalPlayer():ChatPrint( "Only one map can be forced to change!" )
				return
			end
			if not self.panel.listview:GetSelectedLine() then return end
			LocalPlayer():ConCommand( "anus map " .. self.panel.listview:GetLine( self.panel.listview:GetSelectedLine() ):GetColumnText( 1 ) )
		end
	end
	
	
end

anus.registerCategory( Category )


